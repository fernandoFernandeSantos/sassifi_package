export PATH=/usr/local/cuda-7.0/bin:
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:/usr/local/sassi7/extras/CUPTI/lib64 
${BIN_DIR}/hog ${APP_DIR}/1x_pedestrians.jpg --dst_data ${APP_DIR}/GOLD_1x.data --iterations 1 > stdout.txt 2> stderr.txt 
