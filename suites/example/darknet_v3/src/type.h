#ifndef TYPE_H_
#define TYPE_H_

/*
#define HALF 16
#define FLOAT 32
#define DOUBLE 64
*/

#include <stdlib.h>
#include <stdio.h>

#ifdef GPU
#include <cublas_v2.h>
#endif

/*
#if REAL_TYPE == HALF

typedef float float;

#define FLT_MAX 1E+37

//#define REAL_INFINITY 0x7C00
#define REAL_INFINITY 0x7F800000

//---------------------------------------------------------------------------------------------------

#elif REAL_TYPE == FLOAT
*/

//FLOAT----------------------------------------------------------------------------------------------
// Single precision
//typedef float float;
//typedef float float_device;

#define FLT_MAX 1E+37

#define REAL_INFINITY 0x7F800000
//---------------------------------------------------------------------------------------------------
/*
#elif REAL_TYPE == DOUBLE

//DOUBLE----------------------------------------------------------------------------------------------
//Double precision
typedef double float;
typedef float float_device;

#define FLT_MAX 1E+307

#define REAL_INFINITY 0x7FF0000000000000

//---------------------------------------------------------------------------------------------------
#endif // REAL_TYPE MACRO DEFINITION
*/

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Read a file for all precisions
 */
int fread_float_to_float(float* dst, size_t siz, size_t times, FILE* fp);

#if REAL_TYPE == HALF
void run_cuda_gemm_half(cublasHandle_t handle, int TA, int TB, int M, int N, int K, float ALPHA, float *A_gpu,
        int lda, float *B_gpu, int ldb, float BETA, float *C_gpu, int ldc, cudaStream_t st);
#endif

#ifdef __cplusplus
}
 // EXTERN C MACRO
#endif

//typedef struct __device_builtin__ {
//float x;
//float y;
//float z;
//} float3;

#define REAL_RAND_MAX FLT_MAX

#endif /* TYPE_H_ */
