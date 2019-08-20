export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH

${BIN_DIR}/cuda_batched_mxm -size=128 -batch=32 -kernel_type=0 -input_a=${APP_DIR}/mxm_A_128_32.matrix -input_b=${APP_DIR}/mxm_B_128_32.matrix -gold=${APP_DIR}/mxm_GOLD_128_32.matrix -iterations=1  > stdout.txt 2> stderr.txt
