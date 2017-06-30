export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH

${BIN_DIR}/quicksort -size=1048576 -input=${APP_DIR}/quicksort_input_134217728 -gold=${APP_DIR}/quicksort_gold_1048576 -iterations=1 > stdout.txt 2> stderr.txt
