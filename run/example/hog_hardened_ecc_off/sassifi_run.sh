export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH

${BIN_DIR}/hog_hardened_ecc_off /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.critical.1K.txt --iterations 1 > stdout.txt 2> stderr.txt 
