export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
${BIN_DIR}/radixsort_h -size=1048576 -input=${APP_DIR}/radixsort_input_134217728 -gold=${APP_DIR}/radixsort_gold_1048576 -iterations=1 > stdout.txt 2> stderr.txt 
