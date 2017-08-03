/*
 * DeviceVector.h
 *
 *  Created on: 14/06/2017
 *      Author: fernando
 */

#ifndef DEVICEVECTOR_H_
#define DEVICEVECTOR_H_

#include <vector>
#include "cudaUtil.h"
//#define DEBUG_LIGHT 

/**
 * Template for vector on the GPU
 */
template<class T> class DeviceVector {
private:
	T *device_data = nullptr;
	T *host_data = nullptr; // only for fault injection
	bool allocated = false;

	size_t v_size;

	inline void memcopy(T* src, size_t size_count, int type = 0);
	inline void free_memory();
	inline void alloc_memory();

public:
	DeviceVector(size_t siz);
	DeviceVector();
	DeviceVector(const DeviceVector<T>& copy);

	//this constructor will copy the data to gpu
//	DeviceVector(T *data, size_t siz);

	virtual ~DeviceVector();

	//like std::vector
	void resize(size_t siz);
//	T* data(int direction);

	void clear();

	DeviceVector<T>& operator=(const std::vector<T>& other);
	DeviceVector<T>& operator=(const DeviceVector<T>& other);

	//overload only for host side
	T& operator[](int i);
	T* getDeviceData();
	T* getHostData();
	size_t size();

	void fill(T data);

	//to use in fault injection
	void copyDeviceToHost();
	void copyHostToDevice();

};

template<class T>
inline void DeviceVector<T>::free_memory() {
	CudaCheckError();
	CudaSafeCall(cudaFree(this->device_data));
	free(this->host_data);
	this->allocated = false;
}

template<class T>
inline void DeviceVector<T>::alloc_memory() {
//	CudaSafeCall(
//			cudaMallocManaged(&this->device_data, sizeof(T) * this->v_size));
	CudaSafeCall(cudaMalloc(&this->device_data, sizeof(T) * this->v_size));
	this->host_data = (T*) malloc(sizeof(T) * this->v_size);
	if (this->host_data == nullptr) {
		std::cout << "Error on allocating host data\n";
		exit(-1);
	}
	CudaCheckError();
	this->allocated = true;
}
// Unified memory copy constructor allows pass-by-value
template<class T>
DeviceVector<T>::DeviceVector(const DeviceVector<T>& copy) {
#ifdef DEBUG_LIGHT
	std::cout << "DeviceVector(const DeviceVector<T>& copy)\n";
#endif
	if (this->allocated) {
		this->free_memory();
	}

	this->v_size = copy.v_size;
	this->alloc_memory();
	this->memcopy(copy.device_data, this->v_size);
}

template<class T>
DeviceVector<T>::DeviceVector(size_t siz) {
#ifdef DEBUG_LIGHT
	std::cout << "DeviceVector(size_t siz)\n";
#endif
	if (this->allocated) {
		this->free_memory();
	}
	this->v_size = siz;
	this->alloc_memory();
}

template<class T>
DeviceVector<T>::DeviceVector() {
#ifdef DEBUG_LIGHT
	std::cout << "DeviceVector()\n";
#endif
	this->device_data = nullptr;
	this->host_data = nullptr;
	this->v_size = 0;
	this->allocated = false;
}

template<class T>
DeviceVector<T>::~DeviceVector() {
#ifdef DEBUG_LIGHT
	std::cout << "~DeviceVector()\n";
#endif
	if (this->allocated) {
		this->free_memory();
		CudaCheckError();
		this->device_data = nullptr;
		this->host_data = nullptr;
		this->v_size = 0;
		this->allocated = false;
	}
}
//
//template<class T>
//DeviceVector<T>::DeviceVector(T *data, size_t siz) {
//#ifdef DEBUG_LIGHT
//	std::cout << "DeviceVector(T *data, size_t siz)\n";
//#endif
//	if (this->allocated) {
//		this->free_memory();
//	}
//
//	this->v_size = siz;
//	this->alloc_memory();
//	this->memcopy(data, siz);
//}

template<class T>
DeviceVector<T>& DeviceVector<T>::operator=(const DeviceVector<T>& other) {
#ifdef DEBUG_LIGHT
	std::cout << "operator=(const DeviceVector<T>& other)\n";
#endif
	if (this->device_data != other.device_data) { // self-assignment check expected
		T *data = (T*) other.device_data;

		if (this->allocated) {
			this->free_memory();
		}

		this->v_size = other.v_size;
		this->alloc_memory();
		this->memcopy(data, this->v_size);
	}

	return *this;
}

template<class T>
DeviceVector<T>& DeviceVector<T>::operator=(const std::vector<T>& other) {
#ifdef DEBUG_LIGHT
	std::cout << "operator=(const std::vector<T>& other) \n";
#endif
	if (this->host_data != other.data()) { // self-assignment check expected
		T *data = (T*) other.data();
		size_t siz = other.size();

		if (this->allocated) {
			this->free_memory();
		}

		this->v_size = siz;
		this->alloc_memory();
		this->memcopy(data, siz, 1);
	}
	return *this;
}

template<class T>
void DeviceVector<T>::resize(size_t siz) {
#ifdef DEBUG_LIGHT
	std::cout << "resize(size_t siz)\n";
#endif
	if (this->v_size != siz) {
		if (this->v_size != 0) {
			this->free_memory();
		}
		this->v_size = siz;
		this->alloc_memory();
		this->allocated = true;
	}
}

//template<class T>
//T* DeviceVector<T>::data(int direction) {
//#ifdef DEBUG_LIGHT
//	std::cout << "data() \n";
//#endif
//	if (direction == 0){
//		CudaSafeCall(cudaMemcpy(this->host_data, this->device_data, sizeof(T) * size_cont,
//						cudaMemcpyDeviceToHost));
//		return this->host_data;
//	}
//	CudaSafeCall(cudaMemcpy(this->device_data, this->host_data, sizeof(T) * size_cont,
//					cudaMemcpyHostToDevice));
//	return this->device_data;
//
//}

template<class T>
size_t DeviceVector<T>::size() {
#ifdef DEBUG_LIGHT
	std::cout << "size() \n";
#endif
	return this->v_size;
}

template<class T>
T& DeviceVector<T>::operator [](int i) {
#ifdef DEBUG_LIGHT
	std::cout << "operator [] \n";
#endif
	return this->host_data[i];
}

template<class T>
void DeviceVector<T>::memcopy(T* src, size_t size_cont, int type) {
#ifdef DEBUG_LIGHT
	std::cout << "memcopy(T* src, size_t size_cont)\n";
#endif
	if (type == 0) { //device to device
		CudaSafeCall(
				cudaMemcpy(this->device_data, src, sizeof(T) * size_cont,
						cudaMemcpyDeviceToDevice));
//	memcpy(this->device_data, src, sizeof(T) * size_cont);
//		CudaCheckError();
	} else if (type == 1) {
		CudaSafeCall(
				cudaMemcpy(this->device_data, src, sizeof(T) * size_cont,
						cudaMemcpyHostToDevice));
		memcpy(this->host_data, src, sizeof(T) * size_cont);
	}
}

template<class T>
void DeviceVector<T>::clear() {
#ifdef DEBUG_LIGHT
	std::cout << "clear()\n";
#endif
	CudaSafeCall(cudaMemset(this->device_data, 0, sizeof(T) * this->v_size));
	memset(this->host_data, 0, sizeof(T) * this->v_size);
	CudaCheckError();
}

template<class T>
void DeviceVector<T>::fill(T data) {
	CudaSafeCall(cudaMemset(this->device_data, data, sizeof(T) * this->v_size));
	memset(this->host_data, data, sizeof(T) * this->v_size);
	CudaCheckError();
}

template<class T>
T* DeviceVector<T>::getDeviceData() {
	return this->device_data;
}

template<class T>
T* DeviceVector<T>::getHostData() {
	return this->host_data;
}

template<class T>
void DeviceVector<T>::copyDeviceToHost() {
	CudaSafeCall(
			cudaMemcpy(this->host_data, this->device_data,
					sizeof(T) * this->v_size, cudaMemcpyDeviceToHost));
}

template<class T>
void DeviceVector<T>::copyHostToDevice() {
	CudaSafeCall(
			cudaMemcpy(this->device_data, this->host_data, sizeof(T) * this->v_size,
					cudaMemcpyHostToDevice));
}

#endif /* DEVICEVECTOR_H_ */
