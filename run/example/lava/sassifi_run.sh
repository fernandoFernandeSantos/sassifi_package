# SASSI/CUDA
CUDA_BASE_DIR=/usr/local/sassi7
CUDA_LIB_DIR=${CUDA_BASE_DIR}/lib64
CUDA_BIN_DIR=${CUDA_BASE_DIR}/bin
CUPTI_LIB_DIR=${CUDA_BASE_DIR}/extras/CUPTI/lib64

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${CUDA_LIB_DIR}:${CUPTI_LIB_DIR}


${BIN_DIR}/lava -boxes=10 -input_distances=${APP_DIR}/input_distances_10 -input_charges=${APP_DIR}/input_charges_10 -output_gold=${APP_DIR}/GOLD -iterations=1 -streams=1 > stdout.txt 2> stderr.txt 
