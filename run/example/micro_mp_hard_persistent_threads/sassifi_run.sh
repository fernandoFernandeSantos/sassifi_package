export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH

${BIN_DIR}/cuda_micro_persistent_threads --iterations 1 --precision single --redundancy none --inst fma
