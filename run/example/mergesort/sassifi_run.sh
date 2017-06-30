# SASSI/CUDA
CUDA_BASE_DIR=/usr/local/sassi7
CUDA_LIB_DIR=${CUDA_BASE_DIR}/lib64
CUDA_BIN_DIR=${CUDA_BASE_DIR}/bin
CUPTI_LIB_DIR=${CUDA_BASE_DIR}/extras/CUPTI/lib64

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${CUDA_LIB_DIR}:${CUPTI_LIB_DIR}

${BIN_DIR}mergesort -size=1048576 -input=${APP_DIR}/mergesort_input_134217728 -gold=${APP_DIR}/mergesort_gold_1048576 -iterations=1 > stdout.txt 2> stderr.txt 
