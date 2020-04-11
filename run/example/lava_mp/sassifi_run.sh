export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH

OPNUM=1
DMR=none
SIZE=2
PRECISION=single

${BIN_DIR}/cuda_lava -boxes ${SIZE} -streams 1 -iterations 1 -input_distances /home/carol/radiation-benchmarks/data/lava/lava_${PRECISION}_distances_${SIZE} -input_charges /home/carol/radiation-benchmarks/data/lava/lava_${PRECISION}_charges_${SIZE} -output_gold /home/carol/radiation-benchmarks/data/lava/lava_${PRECISION}_gold_${SIZE} -opnum ${OPNUM} -precision ${PRECISION} -redundancy ${DMR} > stdout.txt 2> stderr.txt
