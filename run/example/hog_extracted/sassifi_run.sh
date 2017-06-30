export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
DATASET =/home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.critical.1K.txt
${BIN_DIR}/hog ${DATASET} --iterations 1 > stdout.txt 2> stderr.txt
