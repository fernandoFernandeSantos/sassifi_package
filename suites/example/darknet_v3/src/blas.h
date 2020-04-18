#ifndef BLAS_H
#define BLAS_H
#include "darknet.h"

void flatten(float *x, int size, int layers, int batch, int forward);
void pm(int M, int N, float *A);
float *random_matrix(int rows, int cols);
void time_random_matrix(int TA, int TB, int m, int k, int n);
void reorg_cpu(float *x, int w, int h, int c, int batch, int stride,
		int forward, float *out);

void test_blas();

void inter_cpu(int NX, float *X, int NY, float *Y, int B, float *OUT);
void deinter_cpu(int NX, float *X, int NY, float *Y, int B, float *OUT);
void mult_add_into_cpu(int N, float *X, float *Y, float *Z);

void const_cpu(int N, float ALPHA, float *X, int INCX);
void pow_cpu(int N, float ALPHA, float *X, int INCX, float *Y, int INCY);
void mul_cpu(int N, float *X, int INCX, float *Y, int INCY);

int test_gpu_blas();
void shortcut_cpu(int batch, int w1, int h1, int c1, float *add, int w2,
		int h2, int c2, float s1, float s2, float *out);

void mean_cpu(float *x, int batch, int filters, int spatial, float *mean);
void variance_cpu(float *x, float *mean, int batch, int filters, int spatial,
		float *variance);

void scale_bias(float *output, float *scales, int batch, int n, int size);
void backward_scale_cpu(float *x_norm, float *delta, int batch, int n,
		int size, float *scale_updates);
void mean_delta_cpu(float *delta, float *variance, int batch, int filters,
		int spatial, float *mean_delta);
void variance_delta_cpu(float *x, float *delta, float *mean,
		float *variance, int batch, int filters, int spatial,
		float *variance_delta);
void normalize_delta_cpu(float *x, float *mean, float *variance,
		float *mean_delta, float *variance_delta, int batch, int filters,
		int spatial, float *delta);
void l2normalize_cpu(float *x, float *dx, int batch, int filters,
		int spatial);

void smooth_l1_cpu(int n, float *pred, float *truth, float *delta,
		float *error);
void l2_cpu(int n, float *pred, float *truth, float *delta, float *error);
void l1_cpu(int n, float *pred, float *truth, float *delta, float *error);
void logistic_x_ent_cpu(int n, float *pred, float *truth, float *delta,
		float *error);
void softmax_x_ent_cpu(int n, float *pred, float *truth, float *delta,
		float *error);
void weighted_sum_cpu(float *a, float *b, float *s, int num, float *c);
void weighted_delta_cpu(float *a, float *b, float *s, float *da, float *db,
		float *ds, int n, float *dc);

void softmax(float *input, int n, float temp, int stride, float *output);
void softmax_cpu(float *input, int n, int batch, int batch_offset, int groups,
		int group_offset, int stride, float temp, float *output);
void upsample_cpu(float *in, int w, int h, int c, int batch, int stride,
		int forward, float scale, float *out);

#ifdef GPU
#include "cuda.h"
#include "tree.h"
void constrain_gpu(int N, float ALPHA, float * X, int INCX, cudaStream_t st);

void axpy_gpu(int N, float ALPHA, float * X, int INCX, float * Y, int INCY,
		cudaStream_t st);
void axpy_gpu_offset(int N, float ALPHA, float * X, int OFFX, int INCX, float * Y, int OFFY, int INCY,
		cudaStream_t st);
void copy_gpu(int N, float * X, int INCX, float * Y, int INCY,
		cudaStream_t st);
void copy_gpu_offset(int N, float * X, int OFFX, int INCX, float * Y, int OFFY, int INCY,
		cudaStream_t st);
void add_gpu(int N, float ALPHA, float * X, int INCX,
		cudaStream_t st);
void supp_gpu(int N, float ALPHA, float * X, int INCX,
		cudaStream_t st);
void mask_gpu(int N, float * X, float mask_num, float * mask, float val,
		cudaStream_t st);
void scale_mask_gpu(int N, float * X, float mask_num, float * mask, float scale,
		cudaStream_t st);
void const_gpu(int N, float ALPHA, float *X, int INCX,
		cudaStream_t st);
void pow_gpu(int N, float ALPHA, float *X, int INCX, float *Y, int INCY,
		cudaStream_t st);
void mul_gpu(int N, float *X, int INCX, float *Y, int INCY,
		cudaStream_t st);

void mean_gpu(float *x, int batch, int filters, int spatial, float *mean,
		cudaStream_t st);
void variance_gpu(float *x, float *mean, int batch, int filters, int spatial, float *variance,
		cudaStream_t st);
void normalize_gpu(float *x, float *mean, float *variance, int batch, int filters, int spatial,
		cudaStream_t st);
void l2normalize_gpu(float *x, float *dx, int batch, int filters, int spatial,
		cudaStream_t st);

void normalize_delta_gpu(float *x, float *mean, float *variance, float *mean_delta, float *variance_delta, int batch, int filters, int spatial, float *delta,
		cudaStream_t st);

void fast_mean_delta_gpu(float *delta, float *variance, int batch, int filters, int spatial, float *mean_delta,
		cudaStream_t st);
void fast_variance_delta_gpu(float *x, float *delta, float *mean, float *variance, int batch, int filters, int spatial, float *variance_delta,
		cudaStream_t st);

void fast_variance_gpu(float *x, float *mean, int batch, int filters, int spatial, float *variance,
		cudaStream_t st);
void fast_mean_gpu(float *x, int batch, int filters, int spatial, float *mean,
		cudaStream_t st);
void shortcut_gpu(int batch, int w1, int h1, int c1, float *add, int w2, int h2, int c2, float s1, float s2, float *out,
		cudaStream_t st);
void scale_bias_gpu(float *output, float *biases, int batch, int n, int size,
		cudaStream_t st);
void backward_scale_gpu(float *x_norm, float *delta, int batch, int n, int size, float *scale_updates,
		cudaStream_t st);
void scale_bias_gpu(float *output, float *biases, int batch, int n, int size,
		cudaStream_t st);
void add_bias_gpu(float *output, float *biases, int batch, int n, int size,
		cudaStream_t st);
void backward_bias_gpu(float *bias_updates, float *delta, int batch, int n, int size,
		cudaStream_t st);

void logistic_x_ent_gpu(int n, float *pred, float *truth, float *delta, float *error,
		cudaStream_t st);
void softmax_x_ent_gpu(int n, float *pred, float *truth, float *delta, float *error,
		cudaStream_t st);
void smooth_l1_gpu(int n, float *pred, float *truth, float *delta, float *error,
		cudaStream_t st);
void l2_gpu(int n, float *pred, float *truth, float *delta, float *error,
		cudaStream_t st);
void l1_gpu(int n, float *pred, float *truth, float *delta, float *error,
		cudaStream_t st);
void wgan_gpu(int n, float *pred, float *truth, float *delta, float *error,
		cudaStream_t st);
void weighted_delta_gpu(float *a, float *b, float *s, float *da, float *db, float *ds, int num, float *dc,
		cudaStream_t st);
void weighted_sum_gpu(float *a, float *b, float *s, int num, float *c,
		cudaStream_t st);
void mult_add_into_gpu(int num, float *a, float *b, float *c,
		cudaStream_t st);
void inter_gpu(int NX, float *X, int NY, float *Y, int B, float *OUT,
		cudaStream_t st);
void deinter_gpu(int NX, float *X, int NY, float *Y, int B, float *OUT,
		cudaStream_t st);

void reorg_gpu(float *x, int w, int h, int c, int batch, int stride, int forward, float *out,
		cudaStream_t st);

void softmax_gpu(float *input, int n, int batch, int batch_offset, int groups, int group_offset, int stride, float temp, float *output,
		cudaStream_t st);
void adam_update_gpu(float *w, float *d, float *m, float *v, float B1, float B2, float eps, float decay, float rate, int n, int batch, int t,
		cudaStream_t st);
void adam_gpu(int n, float *x, float *m, float *v, float B1, float B2, float rate, float eps, int t,
		cudaStream_t st);

void flatten_gpu(float *x, int spatial, int layers, int batch, int forward, float *out,
		cudaStream_t st);
void softmax_tree(float *input, int spatial, int batch, int stride, float temp, float *output, tree hier,
		cudaStream_t st);
void upsample_gpu(float *in, int w, int h, int c, int batch, int stride, int forward, float scale, float *out,
		cudaStream_t st);

#endif
#endif
