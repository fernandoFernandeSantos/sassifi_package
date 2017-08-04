#!/bin/bash

# stop after first error
set -e

BASE_DIR=/home/carol/SASSIFI/sassifi_package/suites/example

#first build include dir loghelper
make -C ${BASE_DIR}/include/

for i in LeNetCUDA; #accl hotspot lava lud lulesh mergesort nw quicksort;
do
    echo "###############################################################"
    echo "                     DOING FOR $i"
    echo "###############################################################"

    make -C ${BASE_DIR}/${i} clean
    make -C ${BASE_DIR}/${i} ${i}_generate
    make -C ${BASE_DIR}/${i} generate

    make -C ${BASE_DIR}/${i} clean
    make -C ${BASE_DIR}/${i} ${i} LOGS=1
    make -C ${BASE_DIR}/${i} test
    make -C ${BASE_DIR}/${i} golden

    for j in rf inst_address inst_value;
    do
        ./test.sh ${j} ${i}
    done;
done;



