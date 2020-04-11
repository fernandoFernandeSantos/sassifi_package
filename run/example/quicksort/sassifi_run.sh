export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH

SIZE=1048576 

${BIN_DIR}/quicksort -size=${SIZE} -input=${APP_DIR}/quicksort_input_134217728 -gold=${APP_DIR}/quicksort_gold_${SIZE} -iterations=1 > stdout.txt 2> stderr.txt
