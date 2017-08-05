export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:/usr/local/sassi7/extras/CUPTI/lib64/:/usr/local/sassi7/lib64/:$LD_LIBRARY_PATH

DATA_DIR=/home/carol/radiation-benchmarks/data/lenet

${BIN_DIR}/leNetCUDA rad_test $DATA_DIR/t10k-images-idx3-ubyte $DATA_DIR/t10k-labels-idx1-ubyte $DATA_DIR/lenet_base.weights $DATA_DIR/gold_test 2 1 1 > stdout.txt 2> stderr.txt
