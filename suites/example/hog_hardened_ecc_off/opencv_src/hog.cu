/*M///////////////////////////////////////////////////////////////////////////////////////
 //
 //  IMPORTANT: READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.
 //
 //  By downloading, copying, installing or using the software you agree to this license.
 //  If you do not agree to this license, do not download, install,
 //  copy or use the software.
 //
 //
 //                           License Agreement
 //                For Open Source Computer Vision Library
 //
 // Copyright (C) 2000-2008, Intel Corporation, all rights reserved.
 // Copyright (C) 2009, Willow Garage Inc., all rights reserved.
 // Third party copyrights are property of their respective owners.
 //
 // Redistribution and use in source and binary forms, with or without modification,
 // are permitted provided that the following conditions are met:
 //
 //   * Redistribution's of source code must retain the above copyright notice,
 //     this list of conditions and the following disclaimer.
 //
 //   * Redistribution's in binary form must reproduce the above copyright notice,
 //     this list of conditions and the following disclaimer in the documentation
 //     and/or other materials provided with the distribution.
 //
 //   * The name of the copyright holders may not be used to endorse or promote products
 //     derived from this software without specific prior written permission.
 //
 // This software is provided by the copyright holders and contributors "as is" and
 // any express or implied warranties, including, but not limited to, the implied
 // warranties of merchantability and fitness for a particular purpose are disclaimed.
 // In no event shall the Intel Corporation or contributors be liable for any direct,
 // indirect, incidental, special, exemplary, or consequential damages
 // (including, but not limited to, procurement of substitute goods or services;
 // loss of use, data, or profits; or business interruption) however caused
 // and on any theory of liability, whether in contract, strict liability,
 // or tort (including negligence or otherwise) arising in any way out of
 // the use of this software, even if advised of the possibility of such damage.
 //
 //M*/

//#include "opencv2/gpu/device/common.hpp"
//#include "opencv2/gpu/device/warp_shuffle.hpp"
//#include "opencv2/imgproc/imgproc.hpp"
//#include "opencv2/gpu/gpu.hpp"
#include "opencv2/gpu/device/reduce.hpp"
#include "opencv2/gpu/device/functional.hpp"
#include "hog.cuh"

// Other values are not supported
#define uchar unsigned char
#define CELL_WIDTH 8
#define CELL_HEIGHT 8
#define CELLS_PER_BLOCK_X 2
#define CELLS_PER_BLOCK_Y 2

#define THRESHOLD 0.00000000001

__constant__ int cnbins;
__constant__ int cblock_stride_x;
__constant__ int cblock_stride_y;
__constant__ int cnblocks_win_x;
__constant__ int cnblocks_win_y;
__constant__ int cblock_hist_size;
__constant__ int cblock_hist_size_2up;
__constant__ int cdescr_size;
__constant__ int cdescr_width;

__device__ int kerrors = 0;
__device__ int kernel_sdc = 0;

__global__ void reset_kernel_sdc() {
	kernel_sdc = 0;
}
//__device__ unsigned times = 0;

__device__ int char_to_int(unsigned char *src, int offset) {
	int built = src[offset] & 0xffff;
	built += (src[offset + 1] << 8) & 0xffff;
	built += (src[offset + 2] << 16) & 0xffff;
	built += (src[offset + 3] << 24) & 0xffff;
	return built;
}
/*
 for(int i = ty*n+tx; i < (ty*n+tx + 4); i++){
 unsigned char gk = src[i];
 unsigned char ck = dst[i];
 if ((gk - ck) != 0)
 atomicAdd(&kerrors, 1);
 }
 */

__global__ void sdc_check_kernel(float *src, float *dst, int n) {

	int tx = blockIdx.x * 32 + threadIdx.x;
	int ty = blockIdx.y * 32 + threadIdx.y;
	//int gk = char_to_int(src, (ty*n+tx));
	//int ck = char_to_int(dst, (ty*n+tx));
	float gk = src[(ty * n + tx)];
	float ck = dst[(ty * n + tx)];

	float diff = fabs((fabs(gk) - fabs(ck)));
	if (diff >= THRESHOLD) {
//		if(tx == 0)
//			printf("%lf\n", diff);
		atomicAdd(&kerrors, 1);
	}

	//   atomicAdd(&times, 1);
}

__global__ void sdc_check_kernel_char(unsigned char *src, unsigned char *dst,
		int n, int labels_size) {

	int index = blockIdx.x * 32 + threadIdx.x;
	if (index > labels_size)
		return;
	//int ty = blockIdx.y * 32 + threadIdx.y;
//	int index = (tx);
	int gk = src[index];
	int dk = dst[index];

	int diff = abs(gk) - abs(dk);
	if (abs(diff) >= THRESHOLD)
		atomicAdd(&kerrors, 1);

}

/* Returns the nearest upper power of two, works only for
 the typical GPU thread count (pert block) values */
int power_2up_ext(unsigned int n) {
	if (n < 1)
		return 1;
	else if (n < 2)
		return 2;
	else if (n < 4)
		return 4;
	else if (n < 8)
		return 8;
	else if (n < 16)
		return 16;
	else if (n < 32)
		return 32;
	else if (n < 64)
		return 64;
	else if (n < 128)
		return 128;
	else if (n < 256)
		return 256;
	else if (n < 512)
		return 512;
	else if (n < 1024)
		return 1024;
	return -1; // Input is too big
}

void set_up_constants_ext(int nbins, int block_stride_x, int block_stride_y,
		int nblocks_win_x, int nblocks_win_y) {
	cudaSafeCall(cudaMemcpyToSymbol(cnbins, &nbins, sizeof(nbins)));
	cudaSafeCall(
			cudaMemcpyToSymbol(cblock_stride_x, &block_stride_x,
					sizeof(block_stride_x)));
	cudaSafeCall(
			cudaMemcpyToSymbol(cblock_stride_y, &block_stride_y,
					sizeof(block_stride_y)));
	cudaSafeCall(
			cudaMemcpyToSymbol(cnblocks_win_x, &nblocks_win_x,
					sizeof(nblocks_win_x)));
	cudaSafeCall(
			cudaMemcpyToSymbol(cnblocks_win_y, &nblocks_win_y,
					sizeof(nblocks_win_y)));

	int block_hist_size = nbins * CELLS_PER_BLOCK_X * CELLS_PER_BLOCK_Y;
	cudaSafeCall(
			cudaMemcpyToSymbol(cblock_hist_size, &block_hist_size,
					sizeof(block_hist_size)));

	int block_hist_size_2up = power_2up_ext(block_hist_size);
	cudaSafeCall(
			cudaMemcpyToSymbol(cblock_hist_size_2up, &block_hist_size_2up,
					sizeof(block_hist_size_2up)));

	int descr_width = nblocks_win_x * block_hist_size;
	cudaSafeCall(
			cudaMemcpyToSymbol(cdescr_width, &descr_width,
					sizeof(descr_width)));

	int descr_size = descr_width * nblocks_win_y;
	cudaSafeCall(
			cudaMemcpyToSymbol(cdescr_size, &descr_size, sizeof(descr_size)));
}

//----------------------------------------------------------------------------
// Histogram computation

template<int nblocks> // Number of histogram blocks processed by single GPU thread block
__global__ void compute_hists_kernel_many_blocks_ext(const int img_block_width,
		const cv::gpu::PtrStepf grad, const cv::gpu::PtrStepb qangle,
		float scale, float* block_hists) {
	const int block_x = threadIdx.z;
	const int cell_x = threadIdx.x / 16;
	const int cell_y = threadIdx.y;
	const int cell_thread_x = threadIdx.x & 0xF;

	if (blockIdx.x * blockDim.z + block_x >= img_block_width)
		return;

	extern __shared__ float smem[];
	float* hists = smem;
	float* final_hist = smem + cnbins * 48 * nblocks;

	const int offset_x = (blockIdx.x * blockDim.z + block_x) * cblock_stride_x
			+ 4 * cell_x + cell_thread_x;
	const int offset_y = blockIdx.y * cblock_stride_y + 4 * cell_y;

	const float* grad_ptr = grad.ptr(offset_y) + offset_x * 2;
	const unsigned char* qangle_ptr = qangle.ptr(offset_y) + offset_x * 2;

	// 12 means that 12 pixels affect on block's cell (in one row)
	if (cell_thread_x < 12) {
		float* hist = hists
				+ 12
						* (cell_y * blockDim.z * CELLS_PER_BLOCK_Y + cell_x
								+ block_x * CELLS_PER_BLOCK_X) + cell_thread_x;
		for (int bin_id = 0; bin_id < cnbins; ++bin_id)
			hist[bin_id * 48 * nblocks] = 0.f;

		const int dist_x = -4 + (int) cell_thread_x - 4 * cell_x;

		const int dist_y_begin = -4 - 4 * (int) threadIdx.y;
		for (int dist_y = dist_y_begin; dist_y < dist_y_begin + 12; ++dist_y) {
			float2 vote = *(const float2*) grad_ptr;
			uchar2 bin = *(const uchar2*) qangle_ptr;

			grad_ptr += grad.step / sizeof(float);
			qangle_ptr += qangle.step;

			int dist_center_y = dist_y - 4 * (1 - 2 * cell_y);
			int dist_center_x = dist_x - 4 * (1 - 2 * cell_x);

			float gaussian = ::expf(
					-(dist_center_y * dist_center_y
							+ dist_center_x * dist_center_x) * scale);
			float interp_weight = (8.f - ::fabs(dist_y + 0.5f))
					* (8.f - ::fabs(dist_x + 0.5f)) / 64.f;

			hist[bin.x * 48 * nblocks] += gaussian * interp_weight * vote.x;
			hist[bin.y * 48 * nblocks] += gaussian * interp_weight * vote.y;
		}

		volatile float* hist_ = hist;
		for (int bin_id = 0; bin_id < cnbins; ++bin_id, hist_ += 48 * nblocks) {
			if (cell_thread_x < 6)
				hist_[0] += hist_[6];
			if (cell_thread_x < 3)
				hist_[0] += hist_[3];
			if (cell_thread_x == 0)
				final_hist[((cell_x + block_x * 2) * 2 + cell_y) * cnbins
						+ bin_id] = hist_[0] + hist_[1] + hist_[2];
		}
	}

	__syncthreads();

	float* block_hist = block_hists
			+ (blockIdx.y * img_block_width + blockIdx.x * blockDim.z + block_x)
					* cblock_hist_size;

	int tid = (cell_y * CELLS_PER_BLOCK_Y + cell_x) * 16 + cell_thread_x;
	if (tid < cblock_hist_size)
		block_hist[tid] = final_hist[block_x * cblock_hist_size + tid];
}

void compute_hists_ext(int nbins, int block_stride_x, int block_stride_y,
		int height, int width, const cv::gpu::PtrStepSzf& grad,
		const cv::gpu::PtrStepSzb& qangle, float sigma, float* block_hists) {
	const int nblocks = 1;

	int img_block_width = (width - CELLS_PER_BLOCK_X * CELL_WIDTH
			+ block_stride_x) / block_stride_x;
	int img_block_height = (height - CELLS_PER_BLOCK_Y * CELL_HEIGHT
			+ block_stride_y) / block_stride_y;

	dim3 grid(cv::gpu::divUp(img_block_width, nblocks), img_block_height);
	dim3 threads(32, 2, nblocks);

	cudaSafeCall(
			cudaFuncSetCacheConfig(
					compute_hists_kernel_many_blocks_ext<nblocks>,
					cudaFuncCachePreferL1));

	// Precompute gaussian spatial window parameter
	float scale = 1.f / (2.f * sigma * sigma);

	int hists_size = (nbins * CELLS_PER_BLOCK_X * CELLS_PER_BLOCK_Y * 12
			* nblocks) * sizeof(float);
	int final_hists_size = (nbins * CELLS_PER_BLOCK_X * CELLS_PER_BLOCK_Y
			* nblocks) * sizeof(float);
	int smem = hists_size + final_hists_size;
	compute_hists_kernel_many_blocks_ext<nblocks> <<<grid, threads, smem>>>(
			img_block_width, grad, qangle, scale, block_hists);
	cudaSafeCall(cudaGetLastError());

	cudaSafeCall(cudaDeviceSynchronize());
}

//-------------------------------------------------------------
//  Normalization of histograms via L2Hys_norm
//

template<int size>
__device__ float reduce_smem_ext(float* smem, float val) {
	unsigned int tid = threadIdx.x;
	float sum = val;
	cv::gpu::device::plus<float> temp;
	cv::gpu::device::reduce < size > (smem, sum, tid, temp);

	if (size == 32) {
#if __CUDA_ARCH__ >= 300
		return __shfl(sum, 0);
#else
		return smem[0];
#endif
	} else {
#if __CUDA_ARCH__ >= 300
		if (threadIdx.x == 0)
		smem[0] = sum;
#endif

		__syncthreads();

		return smem[0];
	}
}
///////////////////////////////////////////
//////////////////////////////////////////
////GRADIENT NORMALIZATION HARDENED///////
//////////////////////////////////////////
//////////////////////////////////////////
template<int nthreads, // Number of threads which process one block historgam
		int nblocks> // Number of block hisograms processed by one GPU thread block
__global__ void normalize_hists_kernel_many_blocks_ext(int block_hist_size,
		const int block_hist_size2, int img_block_width,
		const int img_block_width2, float* block_hists, float threshold,
		float threshold2, int& has_sdc) {

	/////////////////////////////////////////////////
	if (block_hist_size != block_hist_size2)
		kernel_sdc = 1;

	if (img_block_width != img_block_width2)
		kernel_sdc = 1;

	if (threshold != threshold2)
		kernel_sdc = 1;
	/////////////////////////////////////////////////

	if (blockIdx.x * blockDim.z + threadIdx.z >= img_block_width)
		return;

	float* hist = block_hists
			+ (blockIdx.y * img_block_width + blockIdx.x * blockDim.z
					+ threadIdx.z) * block_hist_size + threadIdx.x;

	float* hist2 = block_hists
			+ (blockIdx.y * img_block_width2 + blockIdx.x * blockDim.z
					+ threadIdx.z) * block_hist_size2 + threadIdx.x;

	__shared__ float sh_squares[nthreads * nblocks];
	__shared__ float sh_squares2[nthreads * nblocks];

	float* squares = sh_squares + threadIdx.z * nthreads;
	float* squares2 = sh_squares2 + threadIdx.z * nthreads;

	float elem = 0.f;
	float elem2 = 0.f;

	if (threadIdx.x < block_hist_size) {
		elem = hist[0];
		elem2 = hist2[0];
	}

	float sum = reduce_smem_ext<nthreads>(squares, elem * elem);
	float sum2 = reduce_smem_ext<nthreads>(squares2, elem2 * elem2);

	float scale = 1.0f / (::sqrtf(sum) + 0.1f * block_hist_size);
	float scale2 = 1.0f / (::sqrtf(sum2) + 0.1f * block_hist_size2);

	elem = ::min(elem * scale, threshold);
	elem2 = ::min(elem2 * scale2, threshold2);

	sum = reduce_smem_ext<nthreads>(squares, elem * elem);
	sum2 = reduce_smem_ext<nthreads>(squares2, elem2 * elem2);

	scale = 1.0f / (::sqrtf(sum) + 1e-3f);
	scale2 = 1.0f / (::sqrtf(sum2) + 1e-3f);

	if (scale != scale2)
		kernel_sdc = 1;

	if (elem != elem2)
		kernel_sdc = 1;

	if (threadIdx.x < block_hist_size)
		hist[0] = elem * scale;
}

int normalize_hists_ext(int nbins, int block_stride_x, int block_stride_y,
		int height, int width, float* block_hists, float* block_hists2,
		float threshold, int rows) {
	const int nblocks = 1;
	unsigned int errors = 0, errors_prev;
	int has_sdc = 0;

	int block_hist_size = nbins * CELLS_PER_BLOCK_X * CELLS_PER_BLOCK_Y;
	/////////////////////////////////////////////////////////////////////
	int block_hist_size2 = nbins * CELLS_PER_BLOCK_X * CELLS_PER_BLOCK_Y;
	/////////////////////////////////////////////////////////////////////

	int nthreads = power_2up_ext(block_hist_size);
	dim3 threads(nthreads, 1, nblocks);

	int img_block_width = (width - CELLS_PER_BLOCK_X * CELL_WIDTH
			+ block_stride_x) / block_stride_x;
	///////////////////////////////////////
	int img_block_width2 = (width - CELLS_PER_BLOCK_X * CELL_WIDTH
			+ block_stride_x) / block_stride_x;
	float threshold2 = threshold;
	///////////////////////////////////////

	int img_block_height = (height - CELLS_PER_BLOCK_Y * CELL_HEIGHT
			+ block_stride_y) / block_stride_y;
	dim3 grid(cv::gpu::divUp(img_block_width, nblocks), img_block_height);

	/* float *hists_copy;
	 cudaMalloc((void**)&hists_copy, size);
	 cudaMemcpy(hists_copy, block_hists, size, cudaMemcpyHostToDevice);

	 float *hists_backup;
	 cudaMalloc((void**)&hists_backup, (size * sizeof(float)));
	 cudaMemcpy(hists_backup, block_hists, size, cudaMemcpyHostToDevice);*/

	if (nthreads == 32) {
		normalize_hists_kernel_many_blocks_ext<32, nblocks> <<<grid, threads>>>(
				block_hist_size, block_hist_size2, img_block_width,
				img_block_width2, block_hists, threshold, threshold2, has_sdc);
		normalize_hists_kernel_many_blocks_ext<32, nblocks> <<<grid, threads>>>(
				block_hist_size, block_hist_size2, img_block_width,
				img_block_width2, block_hists2, threshold, threshold2, has_sdc);

		cudaMemcpyFromSymbol(&errors_prev, kerrors, sizeof(unsigned int));
		sdc_check_kernel<<<grid, threads>>>(block_hists, block_hists2, rows);
		cudaMemcpyFromSymbol(&errors, kerrors, sizeof(unsigned int));

		if (errors != errors_prev) {
			has_sdc = 1;
		}
		//printf("\n-------\nErrors Prev: %d\nErrors:%d\nhas_sdc:%d", errors_prev, errors, has_sdc);

	} else if (nthreads == 64) {
		normalize_hists_kernel_many_blocks_ext<64, nblocks> <<<grid, threads>>>(
				block_hist_size, block_hist_size2, img_block_width,
				img_block_width2, block_hists, threshold, threshold2, has_sdc);
		normalize_hists_kernel_many_blocks_ext<64, nblocks> <<<grid, threads>>>(
				block_hist_size, block_hist_size2, img_block_width,
				img_block_width2, block_hists2, threshold, threshold2, has_sdc);

		cudaMemcpyFromSymbol(&errors_prev, kerrors, sizeof(unsigned int));
		sdc_check_kernel<<<grid, threads>>>(block_hists, block_hists2, rows);
		cudaMemcpyFromSymbol(&errors, kerrors, sizeof(unsigned int));

		if (errors != errors_prev) {
			has_sdc = 1;
		}
		//printf("\n-------\nErrors Prev: %d\nErrors:%d\nhas_sdc:%d", errors_prev, errors, has_sdc);

	} else if (nthreads == 128) {
		normalize_hists_kernel_many_blocks_ext<64, nblocks> <<<grid, threads>>>(
				block_hist_size, block_hist_size2, img_block_width,
				img_block_width2, block_hists, threshold, threshold2, has_sdc);
		normalize_hists_kernel_many_blocks_ext<64, nblocks> <<<grid, threads>>>(
				block_hist_size, block_hist_size2, img_block_width,
				img_block_width2, block_hists2, threshold, threshold2, has_sdc);

		cudaMemcpyFromSymbol(&errors_prev, kerrors, sizeof(unsigned int));
		sdc_check_kernel<<<grid, threads>>>(block_hists, block_hists2, rows);
		cudaMemcpyFromSymbol(&errors, kerrors, sizeof(unsigned int));

		if (errors != errors_prev) {
			has_sdc = 1;
		}
		//printf("\n-------\nErrors Prev: %d\nErrors:%d\nhas_sdc:%d", errors_prev, errors, has_sdc);
	} else if (nthreads == 256) {
		normalize_hists_kernel_many_blocks_ext<256, nblocks> <<<grid, threads>>>(
				block_hist_size, block_hist_size2, img_block_width,
				img_block_width2, block_hists, threshold, threshold2, has_sdc);
		normalize_hists_kernel_many_blocks_ext<256, nblocks> <<<grid, threads>>>(
				block_hist_size, block_hist_size2, img_block_width,
				img_block_width2, block_hists2, threshold, threshold2, has_sdc);

		cudaMemcpyFromSymbol(&errors_prev, kerrors, sizeof(unsigned int));
		sdc_check_kernel<<<grid, threads>>>(block_hists, block_hists2, rows);
		cudaMemcpyFromSymbol(&errors, kerrors, sizeof(unsigned int));

		if (errors != errors_prev) {
			has_sdc = 1;
		}
		//printf("\n-------\nErrors Prev: %d\nErrors:%d\nhas_sdc:%d", errors_prev, errors, has_sdc);
	} else if (nthreads == 512) {
		normalize_hists_kernel_many_blocks_ext<512, nblocks> <<<grid, threads>>>(
				block_hist_size, block_hist_size2, img_block_width,
				img_block_width2, block_hists, threshold, threshold2, has_sdc);
		normalize_hists_kernel_many_blocks_ext<512, nblocks> <<<grid, threads>>>(
				block_hist_size, block_hist_size2, img_block_width,
				img_block_width2, block_hists2, threshold, threshold2, has_sdc);

		cudaMemcpyFromSymbol(&errors_prev, kerrors, sizeof(unsigned int));
		sdc_check_kernel<<<grid, threads>>>(block_hists, block_hists2, rows);
		cudaMemcpyFromSymbol(&errors, kerrors, sizeof(unsigned int));

		if (errors != errors_prev) {
			has_sdc = 1;
		}
		//printf("\n-------\nErrors Prev: %d\nErrors:%d\nhas_sdc:%d", errors_prev, errors, has_sdc);
	} else
		cv::gpu::error(
				"normalize_hists: histogram's size is too big, try to decrease number of bins",
				__FILE__, __LINE__, "normalize_hists");

	cudaSafeCall(cudaGetLastError());

	cudaSafeCall(cudaDeviceSynchronize());

	int kernel_sdc_copy;
	cudaMemcpyFromSymbol(&kernel_sdc_copy, kernel_sdc, sizeof(int));
	if ((errors != errors_prev) || (kernel_sdc_copy == 1))
		has_sdc = 1;
	//printf("\n---NORMALIZE---\nErrors Prev: %d\nErrors:%d\nhas_sdc:%d\nkernel_sdc: %d", errors_prev, errors, has_sdc, kernel_sdc_copy);
	reset_kernel_sdc<<<1, 1>>>();

	return has_sdc;
}

//---------------------------------------------------------------------
//  Linear SVM based classification
//

// return confidence values not just positive location
template<int nthreads, // Number of threads per one histogram block
		int nblocks> // Number of histogram block processed by single GPU thread block
__global__ void compute_confidence_hists_kernel_many_blocks_ext(
		const int img_win_width, const int img_block_width,
		const int win_block_stride_x, const int win_block_stride_y,
		const float* block_hists, const float* coefs, float free_coef,
		float threshold, float* confidences) {
	const int win_x = threadIdx.z;
	if (blockIdx.x * blockDim.z + win_x >= img_win_width)
		return;

	const float* hist = block_hists
			+ (blockIdx.y * win_block_stride_y * img_block_width
					+ blockIdx.x * win_block_stride_x * blockDim.z + win_x)
					* cblock_hist_size;

	float product = 0.f;
	for (int i = threadIdx.x; i < cdescr_size; i += nthreads) {
		int offset_y = i / cdescr_width;
		int offset_x = i - offset_y * cdescr_width;
		product +=
				coefs[i]
						* hist[offset_y * img_block_width * cblock_hist_size
								+ offset_x];
	}

	__shared__ float products[nthreads * nblocks];

	const int tid = threadIdx.z * nthreads + threadIdx.x;

	cv::gpu::device::reduce < nthreads
			> (products, product, tid, cv::gpu::device::plus<float>());

	if (threadIdx.x == 0)
		confidences[blockIdx.y * img_win_width + blockIdx.x * blockDim.z + win_x] =
				product + free_coef;

}

void compute_confidence_hists_ext(int win_height, int win_width,
		int block_stride_y, int block_stride_x, int win_stride_y,
		int win_stride_x, int height, int width, float* block_hists,
		float* coefs, float free_coef, float threshold, float *confidences) {
	const int nthreads = 256;
	const int nblocks = 1;

	int win_block_stride_x = win_stride_x / block_stride_x;
	int win_block_stride_y = win_stride_y / block_stride_y;
	int img_win_width = (width - win_width + win_stride_x) / win_stride_x;
	int img_win_height = (height - win_height + win_stride_y) / win_stride_y;

	dim3 threads(nthreads, 1, nblocks);
	dim3 grid(cv::gpu::divUp(img_win_width, nblocks), img_win_height);

	cudaSafeCall(
			cudaFuncSetCacheConfig(
					compute_confidence_hists_kernel_many_blocks_ext<nthreads,
							nblocks>, cudaFuncCachePreferL1));

	int img_block_width = (width - CELLS_PER_BLOCK_X * CELL_WIDTH
			+ block_stride_x) / block_stride_x;
	compute_confidence_hists_kernel_many_blocks_ext<nthreads, nblocks> <<<grid,
			threads>>>(img_win_width, img_block_width, win_block_stride_x,
			win_block_stride_y, block_hists, coefs, free_coef, threshold,
			confidences);
	cudaSafeCall(cudaThreadSynchronize());
}

////////////////////////////////////////
////////////////////////////////////////
/////CLASIFY HARDENING//////////////////
////////////////////////////////////////
////////////////////////////////////////

template<int nthreads, // Number of threads per one histogram block
		int nblocks> // Number of histogram block processed by single GPU thread block
__global__ void classify_hists_kernel_many_blocks_ext(int img_win_width,
		const int img_win_width2, int img_block_width,
		const int img_block_width2, int win_block_stride_x,
		const int win_block_stride_x2, int win_block_stride_y,
		const int win_block_stride_y2, const float* block_hists,
		const float* coefs, float free_coef, float free_coef2, float threshold,
		float threshold2, unsigned char* labels) {

	if (img_win_width != img_win_width2)
		//kernel_sdc = 1;
		atomicExch(&kernel_sdc, 1);

	if (img_block_width != img_block_width2)
		kernel_sdc = 1;

	if (win_block_stride_x != win_block_stride_x2)
		atomicExch(&kernel_sdc, 1);

	if (win_block_stride_y != win_block_stride_y2)
		atomicExch(&kernel_sdc, 1);

	if (free_coef != free_coef2)
		atomicExch(&kernel_sdc, 1);

	if (threshold != threshold2)
		atomicExch(&kernel_sdc, 1);

	int win_x = threadIdx.z;
	const int win_x2 = threadIdx.z;

	if (win_x != win_x2)
		atomicExch(&kernel_sdc, 1);

	if (blockIdx.x * blockDim.z + win_x >= img_win_width)
		return;

	const float* hist = block_hists
			+ (blockIdx.y * win_block_stride_y * img_block_width
					+ blockIdx.x * win_block_stride_x * blockDim.z + win_x)
					* cblock_hist_size;

	const float* hist2 = block_hists
			+ (blockIdx.y * win_block_stride_y2 * img_block_width2
					+ blockIdx.x * win_block_stride_x2 * blockDim.z + win_x)
					* cblock_hist_size;

	float product = 0.f;
	float product2 = 0.f;

	for (int i = threadIdx.x; i < cdescr_size; i += nthreads) {
		int offset_y = i / cdescr_width;
		int offset_x = i - offset_y * cdescr_width;
		product +=
				coefs[i]
						* hist[offset_y * img_block_width * cblock_hist_size
								+ offset_x];
		product2 += coefs[i]
				* hist2[offset_y * img_block_width2 * cblock_hist_size
						+ offset_x];
	}

	__shared__ float products[nthreads * nblocks];
	__shared__ float products2[nthreads * nblocks];

	const int tid = threadIdx.z * nthreads + threadIdx.x;

	cv::gpu::device::reduce < nthreads
			> (products, product, tid, cv::gpu::device::plus<float>());
	cv::gpu::device::reduce < nthreads
			> (products2, product2, tid, cv::gpu::device::plus<float>());

	/*if ((product - product2) > 0.1)
	 asm("trap;");*/

	if (win_x != win_x2)
		atomicExch(&kernel_sdc, 1);

	if (threadIdx.x == 0)
		labels[blockIdx.y * img_win_width + blockIdx.x * blockDim.z + win_x] =
				(product + free_coef >= threshold);
}

int classify_hists_ext(int win_height, int win_width, int block_stride_y,
		int block_stride_x, int win_stride_y, int win_stride_x, int height,
		int width, float* block_hists, float* coefs, float free_coef,
		float threshold, unsigned char* labels, unsigned char* labels2,
		int rows, int labels_size) {
	const int nthreads = 256;
	const int nblocks = 1;
	unsigned int errors = 0, errors_prev = 0;
	int has_sdc = 0;

	int win_block_stride_x = win_stride_x / block_stride_x;
	int win_block_stride_x2 = win_stride_x / block_stride_x;

	int win_block_stride_y = win_stride_y / block_stride_y;
	int win_block_stride_y2 = win_stride_y / block_stride_y;

	int img_win_width = (width - win_width + win_stride_x) / win_stride_x;
	int img_win_width2 = (width - win_width + win_stride_x) / win_stride_x;

	float threshold2 = threshold;

	float free_coef2 = free_coef;

	int img_win_height = (height - win_height + win_stride_y) / win_stride_y;

	dim3 threads(nthreads, 1, nblocks);
	dim3 grid(cv::gpu::divUp(img_win_width, nblocks), img_win_height);

	cudaSafeCall(
			cudaFuncSetCacheConfig(
					classify_hists_kernel_many_blocks_ext<nthreads, nblocks>,
					cudaFuncCachePreferL1));

	int img_block_width = (width - CELLS_PER_BLOCK_X * CELL_WIDTH
			+ block_stride_x) / block_stride_x;
	int img_block_width2 = (width - CELLS_PER_BLOCK_X * CELL_WIDTH
			+ block_stride_x) / block_stride_x;

	classify_hists_kernel_many_blocks_ext<nthreads, nblocks> <<<grid, threads>>>(
			img_win_width, img_win_width2, img_block_width, img_block_width2,
			win_block_stride_x, win_block_stride_x2, win_block_stride_y,
			win_block_stride_y2, block_hists, coefs, free_coef, free_coef2,
			threshold, threshold2, labels);

	classify_hists_kernel_many_blocks_ext<nthreads, nblocks> <<<grid, threads>>>(
			img_win_width, img_win_width2, img_block_width, img_block_width2,
			win_block_stride_x, win_block_stride_x2, win_block_stride_y,
			win_block_stride_y2, block_hists, coefs, free_coef, free_coef2,
			threshold, threshold2, labels2);

	long blocks_label_check = ceil(double(labels_size) / double(1024));
	long threads_check = ceil(double(labels_size) / double(blocks_label_check));

	cudaMemcpyFromSymbol(&errors_prev, kerrors, sizeof(unsigned int));
//	printf(
//			"\ngrid x %d y %d z %d\nthreads x %d y %d  z %d\nlabels_size %d threads_check %d  blocks_label_check %d\n",
//			grid.x, grid.y, grid.z, threads.x, threads.y, threads.z,
//			labels_size, threads_check, blocks_label_check);

	sdc_check_kernel_char<<<blocks_label_check, threads_check>>>(labels,
			labels2, rows, labels_size);
	cudaMemcpyFromSymbol(&errors, kerrors, sizeof(unsigned int));

	int kernel_sdc_copy;
//	cudaMemcpyFromSymbol(&kernel_sdc_copy, kernel_sdc, sizeof(int));

//	printf("\n\nTem sdc? %d\n\n", kernel_sdc_copy);

	cudaMemcpyFromSymbol(&kernel_sdc_copy, kernel_sdc, sizeof(int));

	if ((errors != errors_prev) || (kernel_sdc_copy == 1))
		has_sdc = 1;
	/*printf(
			"\n---CLASSIFY---\nErrors Prev: %d\nErrors:%d\nhas_sdc:%d\nkernel_sdc: %d",
			errors_prev, errors, has_sdc, kernel_sdc_copy);*/
	reset_kernel_sdc<<<1, 1>>>();

	cudaSafeCall(cudaGetLastError());

	cudaSafeCall(cudaDeviceSynchronize());

	//printf("\n %d", errors);

	return has_sdc;
}

//----------------------------------------------------------------------------
// Extract descriptors

template<int nthreads>
__global__ void extract_descrs_by_rows_kernel_ext(const int img_block_width,
		const int win_block_stride_x, const int win_block_stride_y,
		const float* block_hists, cv::gpu::PtrStepf descriptors) {
	// Get left top corner of the window in src
	const float* hist = block_hists
			+ (blockIdx.y * win_block_stride_y * img_block_width
					+ blockIdx.x * win_block_stride_x) * cblock_hist_size;

	// Get left top corner of the window in dst
	float* descriptor = descriptors.ptr(blockIdx.y * gridDim.x + blockIdx.x);

	// Copy elements from src to dst
	for (int i = threadIdx.x; i < cdescr_size; i += nthreads) {
		int offset_y = i / cdescr_width;
		int offset_x = i - offset_y * cdescr_width;
		descriptor[i] = hist[offset_y * img_block_width * cblock_hist_size
				+ offset_x];
	}
}

void extract_descrs_by_rows_ext(int win_height, int win_width,
		int block_stride_y, int block_stride_x, int win_stride_y,
		int win_stride_x, int height, int width, float* block_hists,
		cv::gpu::PtrStepSzf descriptors) {
	const int nthreads = 256;

	int win_block_stride_x = win_stride_x / block_stride_x;
	int win_block_stride_y = win_stride_y / block_stride_y;
	int img_win_width = (width - win_width + win_stride_x) / win_stride_x;
	int img_win_height = (height - win_height + win_stride_y) / win_stride_y;
	dim3 threads(nthreads, 1);
	dim3 grid(img_win_width, img_win_height);

	int img_block_width = (width - CELLS_PER_BLOCK_X * CELL_WIDTH
			+ block_stride_x) / block_stride_x;
	extract_descrs_by_rows_kernel_ext<nthreads> <<<grid, threads>>>(
			img_block_width, win_block_stride_x, win_block_stride_y,
			block_hists, descriptors);
	cudaSafeCall(cudaGetLastError());

	cudaSafeCall(cudaDeviceSynchronize());
}

template<int nthreads>
__global__ void extract_descrs_by_cols_kernel_ext(const int img_block_width,
		const int win_block_stride_x, const int win_block_stride_y,
		const float* block_hists, cv::gpu::PtrStepf descriptors) {
	// Get left top corner of the window in src
	const float* hist = block_hists
			+ (blockIdx.y * win_block_stride_y * img_block_width
					+ blockIdx.x * win_block_stride_x) * cblock_hist_size;

	// Get left top corner of the window in dst
	float* descriptor = descriptors.ptr(blockIdx.y * gridDim.x + blockIdx.x);

	// Copy elements from src to dst
	for (int i = threadIdx.x; i < cdescr_size; i += nthreads) {
		int block_idx = i / cblock_hist_size;
		int idx_in_block = i - block_idx * cblock_hist_size;

		int y = block_idx / cnblocks_win_x;
		int x = block_idx - y * cnblocks_win_x;

		descriptor[(x * cnblocks_win_y + y) * cblock_hist_size + idx_in_block] =
				hist[(y * img_block_width + x) * cblock_hist_size + idx_in_block];
	}
}

void extract_descrs_by_cols_ext(int win_height, int win_width,
		int block_stride_y, int block_stride_x, int win_stride_y,
		int win_stride_x, int height, int width, float* block_hists,
		cv::gpu::PtrStepSzf descriptors) {
	const int nthreads = 256;

	int win_block_stride_x = win_stride_x / block_stride_x;
	int win_block_stride_y = win_stride_y / block_stride_y;
	int img_win_width = (width - win_width + win_stride_x) / win_stride_x;
	int img_win_height = (height - win_height + win_stride_y) / win_stride_y;
	dim3 threads(nthreads, 1);
	dim3 grid(img_win_width, img_win_height);

	int img_block_width = (width - CELLS_PER_BLOCK_X * CELL_WIDTH
			+ block_stride_x) / block_stride_x;
	extract_descrs_by_cols_kernel_ext<nthreads> <<<grid, threads>>>(
			img_block_width, win_block_stride_x, win_block_stride_y,
			block_hists, descriptors);
	cudaSafeCall(cudaGetLastError());

	cudaSafeCall(cudaDeviceSynchronize());
}

//----------------------------------------------------------------------------
// Gradients computation

template<int nthreads, int correct_gamma>
__global__ void compute_gradients_8UC4_kernel_ext(int height, int width,
		const cv::gpu::PtrStepb img, float angle_scale, cv::gpu::PtrStepf grad,
		cv::gpu::PtrStepb qangle) {
	const int x = blockIdx.x * blockDim.x + threadIdx.x;

	const uchar4* row = (const uchar4*) img.ptr(blockIdx.y);

	__shared__ float sh_row[(nthreads + 2) * 3];

	uchar4 val;
	if (x < width)
		val = row[x];
	else
		val = row[width - 2];

	sh_row[threadIdx.x + 1] = val.x;
	sh_row[threadIdx.x + 1 + (nthreads + 2)] = val.y;
	sh_row[threadIdx.x + 1 + 2 * (nthreads + 2)] = val.z;

	if (threadIdx.x == 0) {
		val = row[::max(x - 1, 1)];
		sh_row[0] = val.x;
		sh_row[(nthreads + 2)] = val.y;
		sh_row[2 * (nthreads + 2)] = val.z;
	}

	if (threadIdx.x == blockDim.x - 1) {
		val = row[::min(x + 1, width - 2)];
		sh_row[blockDim.x + 1] = val.x;
		sh_row[blockDim.x + 1 + (nthreads + 2)] = val.y;
		sh_row[blockDim.x + 1 + 2 * (nthreads + 2)] = val.z;
	}

	__syncthreads();
	if (x < width) {
		float3 a, b;

		b.x = sh_row[threadIdx.x + 2];
		b.y = sh_row[threadIdx.x + 2 + (nthreads + 2)];
		b.z = sh_row[threadIdx.x + 2 + 2 * (nthreads + 2)];
		a.x = sh_row[threadIdx.x];
		a.y = sh_row[threadIdx.x + (nthreads + 2)];
		a.z = sh_row[threadIdx.x + 2 * (nthreads + 2)];

		float3 dx;
		if (correct_gamma)
			dx = make_float3(::sqrtf(b.x) - ::sqrtf(a.x),
					::sqrtf(b.y) - ::sqrtf(a.y), ::sqrtf(b.z) - ::sqrtf(a.z));
		else
			dx = make_float3(b.x - a.x, b.y - a.y, b.z - a.z);

		float3 dy = make_float3(0.f, 0.f, 0.f);

		if (blockIdx.y > 0 && blockIdx.y < height - 1) {
			val = ((const uchar4*) img.ptr(blockIdx.y - 1))[x];
			a = make_float3(val.x, val.y, val.z);

			val = ((const uchar4*) img.ptr(blockIdx.y + 1))[x];
			b = make_float3(val.x, val.y, val.z);

			if (correct_gamma)
				dy = make_float3(::sqrtf(b.x) - ::sqrtf(a.x),
						::sqrtf(b.y) - ::sqrtf(a.y),
						::sqrtf(b.z) - ::sqrtf(a.z));
			else
				dy = make_float3(b.x - a.x, b.y - a.y, b.z - a.z);
		}

		float best_dx = dx.x;
		float best_dy = dy.x;

		float mag0 = dx.x * dx.x + dy.x * dy.x;
		float mag1 = dx.y * dx.y + dy.y * dy.y;
		if (mag0 < mag1) {
			best_dx = dx.y;
			best_dy = dy.y;
			mag0 = mag1;
		}

		mag1 = dx.z * dx.z + dy.z * dy.z;
		if (mag0 < mag1) {
			best_dx = dx.z;
			best_dy = dy.z;
			mag0 = mag1;
		}

		mag0 = ::sqrtf(mag0);

		float ang = (::atan2f(best_dy, best_dx) + CV_PI_F) * angle_scale - 0.5f;
		int hidx = (int) ::floorf(ang);
		ang -= hidx;
		hidx = (hidx + cnbins) % cnbins;

		((uchar2*) qangle.ptr(blockIdx.y))[x] = make_uchar2(hidx,
				(hidx + 1) % cnbins);
		((float2*) grad.ptr(blockIdx.y))[x] = make_float2(mag0 * (1.f - ang),
				mag0 * ang);
	}
}

void compute_gradients_8UC4_ext(int nbins, int height, int width,
		const cv::gpu::PtrStepSzb& img, float angle_scale,
		cv::gpu::PtrStepSzf grad, cv::gpu::PtrStepSzb qangle,
		bool correct_gamma) {
	(void) nbins;
	const int nthreads = 256;

	dim3 bdim(nthreads, 1);
	dim3 gdim(cv::gpu::divUp(width, bdim.x), cv::gpu::divUp(height, bdim.y));

	if (correct_gamma)
		compute_gradients_8UC4_kernel_ext<nthreads, 1> <<<gdim, bdim>>>(height,
				width, img, angle_scale, grad, qangle);
	else
		compute_gradients_8UC4_kernel_ext<nthreads, 0> <<<gdim, bdim>>>(height,
				width, img, angle_scale, grad, qangle);

	cudaSafeCall(cudaGetLastError());

	cudaSafeCall(cudaDeviceSynchronize());
}

template<int nthreads, int correct_gamma>
__global__ void compute_gradients_8UC1_kernel_ext(int height, int width,
		const cv::gpu::PtrStepb img, float angle_scale, cv::gpu::PtrStepf grad,
		cv::gpu::PtrStepb qangle) {
	const int x = blockIdx.x * blockDim.x + threadIdx.x;

	const unsigned char* row = (const unsigned char*) img.ptr(blockIdx.y);

	__shared__ float sh_row[nthreads + 2];

	if (x < width)
		sh_row[threadIdx.x + 1] = row[x];
	else
		sh_row[threadIdx.x + 1] = row[width - 2];

	if (threadIdx.x == 0)
		sh_row[0] = row[::max(x - 1, 1)];

	if (threadIdx.x == blockDim.x - 1)
		sh_row[blockDim.x + 1] = row[::min(x + 1, width - 2)];

	__syncthreads();
	if (x < width) {
		float dx;

		if (correct_gamma)
			dx = ::sqrtf(sh_row[threadIdx.x + 2])
					- ::sqrtf(sh_row[threadIdx.x]);
		else
			dx = sh_row[threadIdx.x + 2] - sh_row[threadIdx.x];

		float dy = 0.f;
		if (blockIdx.y > 0 && blockIdx.y < height - 1) {
			float a = ((const unsigned char*) img.ptr(blockIdx.y + 1))[x];
			float b = ((const unsigned char*) img.ptr(blockIdx.y - 1))[x];
			if (correct_gamma)
				dy = ::sqrtf(a) - ::sqrtf(b);
			else
				dy = a - b;
		}
		float mag = ::sqrtf(dx * dx + dy * dy);

		float ang = (::atan2f(dy, dx) + CV_PI_F) * angle_scale - 0.5f;
		int hidx = (int) ::floorf(ang);
		ang -= hidx;
		hidx = (hidx + cnbins) % cnbins;

		((uchar2*) qangle.ptr(blockIdx.y))[x] = make_uchar2(hidx,
				(hidx + 1) % cnbins);
		((float2*) grad.ptr(blockIdx.y))[x] = make_float2(mag * (1.f - ang),
				mag * ang);
	}
}

void compute_gradients_8UC1_ext(int nbins, int height, int width,
		const cv::gpu::PtrStepSzb& img, float angle_scale,
		cv::gpu::PtrStepSzf grad, cv::gpu::PtrStepSzb qangle,
		bool correct_gamma) {
	(void) nbins;
	const int nthreads = 256;

	dim3 bdim(nthreads, 1);
	dim3 gdim(cv::gpu::divUp(width, bdim.x), cv::gpu::divUp(height, bdim.y));

	if (correct_gamma)
		compute_gradients_8UC1_kernel_ext<nthreads, 1> <<<gdim, bdim>>>(height,
				width, img, angle_scale, grad, qangle);
	else
		compute_gradients_8UC1_kernel_ext<nthreads, 0> <<<gdim, bdim>>>(height,
				width, img, angle_scale, grad, qangle);

	cudaSafeCall(cudaGetLastError());

	cudaSafeCall(cudaDeviceSynchronize());
}

//-------------------------------------------------------------------
// Resize

texture<uchar4, 2, cudaReadModeNormalizedFloat> resize8UC4_tex;
texture<uchar, 2, cudaReadModeNormalizedFloat> resize8UC1_tex;

__global__ void resize_for_hog_kernel_ext(float sx, float sy,
		cv::gpu::PtrStepSz<uchar> dst, int colOfs) {
	unsigned int x = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned int y = blockIdx.y * blockDim.y + threadIdx.y;

	if (x < dst.cols && y < dst.rows)
		dst.ptr(y)[x] = tex2D(resize8UC1_tex, x * sx + colOfs, y * sy) * 255;
}

__global__ void resize_for_hog_kernel_ext(float sx, float sy,
		cv::gpu::PtrStepSz<uchar4> dst, int colOfs) {
	unsigned int x = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned int y = blockIdx.y * blockDim.y + threadIdx.y;

	if (x < dst.cols && y < dst.rows) {
		float4 val = tex2D(resize8UC4_tex, x * sx + colOfs, y * sy);
		dst.ptr(y)[x] = make_uchar4(val.x * 255, val.y * 255, val.z * 255,
				val.w * 255);
	}
}

template<class T, class TEX>
static void resize_for_hog_ext(const cv::gpu::PtrStepSzb& src,
		cv::gpu::PtrStepSzb dst, TEX& tex) {
	tex.filterMode = cudaFilterModeLinear;

	size_t texOfs = 0;
	int colOfs = 0;

	cudaChannelFormatDesc desc = cudaCreateChannelDesc<T>();
	cudaSafeCall(
			cudaBindTexture2D(&texOfs, tex, src.data, desc, src.cols, src.rows,
					src.step));

	if (texOfs != 0) {
		colOfs = static_cast<int>(texOfs / sizeof(T));
		cudaSafeCall(cudaUnbindTexture(tex));
		cudaSafeCall(
				cudaBindTexture2D(&texOfs, tex, src.data, desc, src.cols,
						src.rows, src.step));
	}

	dim3 threads(32, 8);
	dim3 grid(cv::gpu::divUp(dst.cols, threads.x),
			cv::gpu::divUp(dst.rows, threads.y));

	float sx = static_cast<float>(src.cols) / dst.cols;
	float sy = static_cast<float>(src.rows) / dst.rows;

	resize_for_hog_kernel_ext<<<grid, threads>>>(sx, sy,
			(cv::gpu::PtrStepSz<T>) dst, colOfs);
	cudaSafeCall(cudaGetLastError());

	cudaSafeCall(cudaDeviceSynchronize());

	cudaSafeCall(cudaUnbindTexture(tex));
}

void resize_8UC1(const cv::gpu::PtrStepSzb& src, cv::gpu::PtrStepSzb dst) {
	resize_for_hog_ext<uchar>(src, dst, resize8UC1_tex);
}
void resize_8UC4(const cv::gpu::PtrStepSzb& src, cv::gpu::PtrStepSzb dst) {
	resize_for_hog_ext<uchar4>(src, dst, resize8UC4_tex);
}
