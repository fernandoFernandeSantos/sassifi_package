export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH

${BIN_DIR}/nw 2048 10 ${APP_DIR}/input_2048 ${APP_DIR}/gold_2048 1 > stdout.txt 2> stderr.txt
