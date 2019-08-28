export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH
SIZE=112
BATCH=32
KTYPE=1
${BIN_DIR}/cuda_batched_mxm -size=${SIZE} -batch=${BATCH} -kernel_type=${KTYPE} -input_a=${APP_DIR}/mxm_A_${SIZE}_${BATCH}.matrix -input_b=${APP_DIR}/mxm_B_${SIZE}_${BATCH}.matrix -gold=${APP_DIR}/mxm_GOLD_${SIZE}_${BATCH}.matrix -iterations=1  > stdout.txt 2> stderr.txt
