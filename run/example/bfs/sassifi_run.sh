export PATH=/usr/local/cuda-7.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-7.0/lib64:$LD_LIBRARY_PATH

RADDIR=/home/carol/radiation-benchmarks/data/bfs

${BIN_DIR}/cudaBFS --input ${RADDIR}/graph1MW_6.txt --gold ${RADDIR}/gold.data --iterations 1 --verbose  > stdout.txt 2> stderr.txt
sed -i '/LOGFILENAME/c\REPLACED.' stdout.txt 
sed -i '/Overall time/c\REPLACED.'stdout.txt 
sed -i '/Wasted time/c\REPLACED.' stdout.txt 

