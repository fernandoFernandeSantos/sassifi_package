export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

${BIN_DIR}/lud -matrix_size=2048 -reps=1 -input=${APP_DIR}/lud_input_2048 -gold=${APP_DIR}/lud_gold_2048 > stdout.txt 2> stderr.txt 
