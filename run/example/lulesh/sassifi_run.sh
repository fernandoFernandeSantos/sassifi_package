export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

#	 ./lulesh -s 50 -i 1 -g 0 gold_50
${BIN_DIR}/lulesh  -s 50 -i 1 -g 0 ${APP_DIR}/gold_50 > stdout.txt 2> stderr.txt 
