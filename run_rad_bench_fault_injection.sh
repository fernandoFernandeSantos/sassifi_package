#!/bin/bash

# stop after first error
set -e

BASE_DIR=/home/carol/SASSIFI/sassifi_package/suites/example

#first build include dir loghelper
make -C ${BASE_DIR}/include/

for i in gemm_tensorcores; #LeNetCUDA accl hotspot lava lud lulesh mergesort nw quicksort;
do
    echo "###############################################################"
    echo "                     DOING FOR $i"
    echo "###############################################################"

    export SASSIFI_HOME=/home/carol/SASSIFI/sassifi_package/
    export SASSI_SRC=/home/carol/SASSIFI/SASSI
    export INST_LIB_DIR=$SASSI_SRC/instlibs/lib
    export CCDIR=/usr
    export CUDA_BASE_DIR=/usr/local/sassi7
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CUDA_BASE_DIR/lib64/:$CUDA_BASE_DIR/extras/CUPTI/lib64
    
    make -C ${BASE_DIR}/${i} 
    make -C ${BASE_DIR}/${i} generate
    make -C ${BASE_DIR}/${i} test
    make -C ${BASE_DIR}/${i} golden

    for j in inst_value;
    do
        ./test.sh ${i} ${j}
    done;
done;



