#!/bin/bash
set -x 

################################################
# Step 1: Set environment variables
################################################
printf "\nStep 1: Setting environment variables"
if [ `hostname -s` == "carolk402" ]; then
    export SASSIFI_HOME=/home/carol/SASSIFI/sassifi_package/
    export SASSI_SRC=/home/carol/SASSI/
    export INST_LIB_DIR=$SASSI_SRC/instlibs/lib/
    export CCDIR=/usr/bin/
    export CUDA_BASE_DIR=/usr/local/sassi7/
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CUDA_BASE_DIR/lib64/:$CUDA_BASE_DIR/extras/CUPTI/lib64/
else
    printf "\nPlease update SASSI_SRC, INST_LIB_DIR, CCDIR, CUDA_BASE_DIR, and LD_LIBRARY_PATH environment variables\n"
    exit -1;
fi

export BENCHMARK=$1
SUITE_FOLDER=$SASSIFI_HOME/suites/example/$BENCHMARK
inst_rf=$2

################################################
# Step 4.a: Build the app without instrumentation.
# Collect golden stdout and stderr files.
################################################
printf "\nStep 4.1: Collect golden stdout.txt and stderr.txt files"
cd $SUITE_FOLDER
make  2> stderr.txt
make golden
if [ $? -ne 0 ]; then
    echo "Return code was not zero: $?"
        exit -1;
fi

# process the stderr.txt file created during compilation to extract number of
# registers allocated per kernel
python $SASSIFI_HOME/scripts/process_kernel_regcount.py $BENCHMARK sm_35 stderr.txt

################################################
# Step 5: Build the app for profiling and
# collect the instruction profile
################################################
printf "\nStep 5: Profile the application"
make OPTION=profiler
make test 
if [ $? -ne 0 ]; then
    echo "Return code was not zero: $?"
        exit -1;
fi

################################################
# Step 6: Build the app for error injectors
################################################
printf "\nStep 6: Prepare application for error injection"
make OPTION=inst_injector logs=-DLOGS
make OPTION=rf_injector logs=-DLOGS

################################################
# Step 7.b: Generate injection list for the 
# selected error injection model
################################################
printf "\nStep 7.2: Generate injection list for instruction-level error injections"
cd -
cd scripts/
python generate_injection_list.py $inst_rf 
if [ $? -ne 0 ]; then
    echo "Return code was not zero: $?"
        exit -1;
fi

################################################
# Step 8: Run the error injection campaign 
################################################
printf "\nStep 8: Run the error injection campaign"
python run_injections.py $inst_rf standalone # to run the injection campaign on a single machine with single gpu
# python run_injections.py $inst_rf multigpu # to run the injection campaign on a single machine with multiple gpus. 

################################################
# Step 9: Parse the results
################################################
printf "\nStep 9: Parse results"
python parse_results.py $inst_rf

