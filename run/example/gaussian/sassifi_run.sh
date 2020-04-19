export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH

SIZE=8192

${APP_DIR}/$(EXEC) --size ${SIZE} --input ${APP_DIR}/input_${SIZE}.data --gold ${APP_DIR}/gold_${SIZE}.data --verbose --iterations 1 > stdout.txt 2>stderr.txt
