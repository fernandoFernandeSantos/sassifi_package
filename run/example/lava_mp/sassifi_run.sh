export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH

OPNUM=1
DMR=dmrmixed
SIZE=23

${BIN_DIR}/cuda_lava -boxes ${SIZE} -streams 1 -iterations 1 -input_distances /home/carol/radiation-benchmarks/data/lava/lava_double_distances_23 -input_charges /home/carol/radiation-benchmarks/data/lava/lava_double_charges_23 -output_gold /home/carol/radiation-benchmarks/data/lava/lava_double_gold_23 -opnum ${OPNUM} -precision double -redundancy ${DMR} -opnum 1 > stdout.txt 2> stderr.txt
