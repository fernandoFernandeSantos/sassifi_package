export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH

OPNUM=1
DMR=none
SIZE=8

${BIN_DIR}/cuda_lava -boxes ${SIZE} -streams 1 -iterations 1 -input_distances /home/carol/radiation-benchmarks/data/lava/lava_double_distances_${SIZE} -input_charges /home/carol/radiation-benchmarks/data/lava/lava_double_charges_${SIZE} -output_gold /home/carol/radiation-benchmarks/data/lava/lava_double_gold_${SIZE} -opnum ${OPNUM} -precision double -redundancy ${DMR} > stdout.txt 2> stderr.txt
