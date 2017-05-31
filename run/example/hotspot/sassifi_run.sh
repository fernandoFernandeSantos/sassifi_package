export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
${BIN_DIR}/hotspot -size=1024 -sim_time=1 -streams=1 -temp_file=${APP_DIR}/temp_1024 -power_file=${APP_DIR}/power_1024 -gold_file=${APP_DIR}/gold_1024_1 -iterations=1 -verbose > stdout.txt 2> stderr.txt 
