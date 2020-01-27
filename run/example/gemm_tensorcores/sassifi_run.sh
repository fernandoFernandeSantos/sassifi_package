export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH

OPNUM=1
DMR=none
ALPHA=1.0
BETA=0.0
SIZE=4096
PRECISION=float

${BIN_DIR}/gemm --size ${SIZE} --precision ${PRECISION} --dmr ${DMR} --iterations 1 --alpha ${ALPHA} --beta ${BETA} --input_a ${APP_DIR}/a_float_${ALPHA}_${BETA}_${SIZE}_cublas_0_tensor_0.matrix --input_b ${APP_DIR}/b_float_${ALPHA}_${BETA}_${SIZE}_cublas_0_tensor_0.matrix --input_c ${APP_DIR}/c_float_${ALPHA}_${BETA}_${SIZE}_cublas_0_tensor_0.matrix  --gold ${APP_DIR}/g_float_${ALPHA}_${BETA}_${SIZE}_cublas_0_tensor_0.matrix --opnum ${OPNUM}  > stdout.txt 2> stderr.txt

#${BIN_DIR}/gemm --opnum ${OPNUM} --size ${SIZE}  --generate 0 --precision double --dmr ${DMR} --iterations 1 --alpha 0.9 --beta 0.1 --input_a ${APP_DIR}/input_a.matrix --input_b ${APP_DIR}/input_b.matrix --input_c ${APP_DIR}/input_c.matrix --gold ${APP_DIR}/gold.matrix  > stdout.txt 2> stderr.txt1
