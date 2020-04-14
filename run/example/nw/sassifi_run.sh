export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH

#./nw 16384 10 ./input_16384 ./gold_16384 1 0
SIZE=16384

${BIN_DIR}/nw ${SIZE} 10 ${APP_DIR}/input_${SIZE} ${APP_DIR}/gold_${SIZE} 1 0 > stdout.txt 2> stderr.txt
sed -i '/kernel time/c\REPLACED.' stdout.txt 
sed -i '/LOGFILE/c\REPLACED.' stdout.txt 
sed -i '/read../c\REPLACED.' stdout.txt 

