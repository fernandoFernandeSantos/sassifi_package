# SASSI/CUDA
#CUDA_BASE_DIR=/usr/local/sassi7
#CUDA_LIB_DIR=${CUDA_BASE_DIR}/lib64
#CUDA_BIN_DIR=${CUDA_BASE_DIR}/bin
#CUPTI_LIB_DIR=${CUDA_BASE_DIR}/extras/CUPTI/lib64
#export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${CUDA_LIB_DIR}:${CUPTI_LIB_DIR}

export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH

${BIN_DIR}/accl 2 1  ${APP_DIR}/2Frames.pgm ${APP_DIR}/GOLD_2Frames 1 -verbose > stdout.txt 2> stderr.txt 
