export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH

${BIN_DIR}/lava -boxes=10 -input_distances=${APP_DIR}/input_distances_10 -input_charges=${APP_DIR}/input_charges_10 -output_gold=${APP_DIR}/GOLD -iterations=1 -streams=1 > stdout.txt 2> stderr.txt
