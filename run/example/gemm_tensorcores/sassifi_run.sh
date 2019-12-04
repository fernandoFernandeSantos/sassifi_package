export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH

OPNUM=1
DMR=mixed
SIZE=512

${BIN_DIR}/gemm --opnum ${OPNUM} --size ${SIZE}  --generate 0 --precision double --dmr ${DMR} --iterations 1 --alpha 0.9 --beta 0.1 --input_a ${APP_DIR}/input_a.matrix --input_b ${APP_DIR}/input_b.matrix --input_c ${APP_DIR}/input_c.matrix --gold ${APP_DIR}/gold.matrix  > stdout.txt 2> stderr.txt
