export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:/usr/local/sassi7/extras/CUPTI/lib64/:/usr/local/sassi7/lib64/:$LD_LIBRARY_PATH

RAD_DIR=/home/carol/radiation-benchmarks

${BIN_DIR}/darknet test_radiation -d $RAD_DIR/data/darknet/fault_injection.csv -n 1 -s 1 -a 0 > stdout.txt 2> stderr.txt
sed -i '/Iteration 0 - image/c\REPLACED.' stdout.txt 

