export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
${BIN_DIR}/hog ${APP_DIR}/1x_pedestrians.jpg --dst_data ${APP_DIR}/GOLD_1x.data --iterations 1 > stdout.txt 2> stderr.txt 
