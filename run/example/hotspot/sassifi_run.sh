export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH
${BIN_DIR}/hotspot -size=1024 -sim_time=10 -streams=1 -input_temp=${APP_DIR}/temp_1024 -input_power=${APP_DIR}/power_1024 -gold_temp=${APP_DIR}/gold_1024_1 -iterations=1 > stdout.txt 2> stderr.txt
