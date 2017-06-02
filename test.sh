#!/bin/bash

# stop after first error
set -e

#~ printf "Steps 1, 2, 3, 4(b), 4(c), and 7(a) mentioned in \"Setting up and running SASSIFI\" section in sassi-user-guide should be completed before proceeding further. Are these steps completed? [y/n]: "
#~ read answer

#~ if [ "$answer" != "y" ]; then
  #~ printf "\nCannot proceed further\n"
    #~ exit -1;
#~ fi

#~ printf "Which mode do you want to run SASSIFI in? [inst_value/inst_address/rf/all] (default is inst_value): "
#~ read inst_rf

#~ if [ "$inst_rf" == "inst_value" ] || [ "$inst_rf" == "inst_address" ] || [ "$inst_rf" == "rf" ] || [ "$inst_rf" == "all" ] ; then
  #~ printf "Okay, $inst_rf\n"
#~ else
    #~ inst_rf="inst_value"
  #~ printf "Proceeding with the default option, $inst_rf\n"
#~ fi

# Uncomment for verbose output
# set -x



################################################
# Step 1: Set environment variables
################################################
printf "\nStep 1: Setting environment variables\n"
if [ `hostname -s` == "carol" ]; then
    export SASSIFI_HOME=/home/carol/SASSIFI/sassifi_package/
    export SASSI_SRC=/home/carol/SASSIFI/SASSI/
    export INST_LIB_DIR=$SASSI_SRC/instlibs/lib/
    export CCDIR=/usr/
    export CUDA_BASE_DIR=/usr/local/sassi7/
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CUDA_BASE_DIR/lib64/:$CUDA_BASE_DIR/extras/CUPTI/lib64/
else
    printf "\nPlease update SASSIFI_HOME, SASSI_SRC, INST_LIB_DIR, CCDIR, CUDA_BASE_DIR, and LD_LIBRARY_PATH environment variables and modify the hostname string in test.sh to fix this error\n"
    exit -1;
fi


################################################
################################################
#EDITED BY FERNANDO
################################################
################################################
#first parameter is the error model
inst_rf=$1
if [ "$inst_rf" == "inst_value" ] || [ "$inst_rf" == "inst_address" ] || [ "$inst_rf" == "rf" ] || [ "$inst_rf" == "all" ] ; then
  printf "Okay, $inst_rf\n"
else
  printf "set the first parameter with inst_value/inst_address/rf/all\n"
  exit -1;
fi

#second parameter is the benchmark
benchmark=$2

if [ -d "suites/example/$benchmark" ] ; then
    printf "Okay, it will run for $benchmark\n"
    export BENCHMARK=$benchmark
    if [ ! -f "$SASSIFI_HOMElogs_sdcs_$benchmark_$inst_rf.csv" ] ; then
		if [ "$inst_rf"  == "all" ] ; then
			echo "log_file,has_sdc,inj_kname,inj_kcount,inj_igid,inj_fault_model,inj_inst_id,inj_destination_id,inj_bit_location,finished,hardened" > ${SASSIFI_HOME}logs_sdcs_${benchmark}_inst_address.csv
			echo "log_file,has_sdc,inj_kname,inj_kcount,inj_igid,inj_fault_model,inj_inst_id,inj_destination_id,inj_bit_location,finished,hardened" > ${SASSIFI_HOME}logs_sdcs_${benchmark}_inst_value.csv
			echo "log_file,has_sdc,inj_kname,inj_kcount,inj_igid,inj_fault_model,inj_inst_id,inj_destination_id,inj_bit_location,finished,hardened" > ${SASSIFI_HOME}logs_sdcs_${benchmark}_rf.csv

		else
			echo "log_file,has_sdc,inj_kname,inj_kcount,inj_igid,inj_fault_model,inj_inst_id,inj_destination_id,inj_bit_location,finished,hardened" > ${SASSIFI_HOME}logs_sdcs_${benchmark}_${inst}_rf.csv
		fi

    fi
else
    printf "$benchmark not found\n"
    exit -1;
fi

################################################
# Step 4.a: Build the app without instrumentation.
# Collect golden stdout and stderr files.
################################################
printf "\nStep 4.1: Collect golden stdout.txt and stderr.txt files"
cd suites/example/$benchmark/
make LOGS=1 2> stderr.txt
make golden

# process the stderr.txt file created during compilation to extract number of
# registers allocated per kernel. Provide the SM architecture string (e.g.,
# sm_35) to process the number of registers per kernel for the target
# architecture you are interested in. We may have compiled the workload for
# multiple targets.
python $SASSIFI_HOME/scripts/process_kernel_regcount.py simple_add sm_35 stderr.txt

################################################
# Step 5: Build the app for profiling and
# collect the instruction profile
################################################
printf "\nStep 5: Profile the application"
make OPTION=profiler
make test

################################################
# Step 6: Build the app for error injections,
# and install the binaries in the right place
# ($SASSIFI_HOME/bin/$OPTION/example)
################################################
printf "\nStep 6: Prepare application for error injection"
if [ $inst_rf == "all" ] ; then
    make OPTION=inst_value_injector
    make OPTION=inst_address_injector
    make OPTION=rf_injector
else
    make OPTION=$inst_rf\_injector
fi

################################################
# Step 7.b: Generate injection list for the
# selected error injection model
################################################
printf "\nStep 7.2: Generate injection list for instruction-level error injections"
cd -
cd scripts/
if [ $inst_rf == "all" ] ; then
    python generate_injection_list.py inst_address
    python generate_injection_list.py inst_value
    python generate_injection_list.py rf
else
    python generate_injection_list.py $inst_rf
fi

################################################
# Step 8: Run the error injection campaign
################################################
printf "\nStep 8: Run the error injection campaign"
if [ $inst_rf == "all" ] ; then
    python run_injections.py inst_address standalone # to run the injection campaign on a single machine with single gpu
    python run_injections.py inst_value standalone
    python run_injections.py rf standalone
else
    python run_injections.py $inst_rf standalone # to run the injection campaign on a single machine with single gpu
    # python run_injections.py $inst_rf multigpu # to run the injection campaign on a single machine with multiple gpus.
fi

################################################
# Step 9: Parse the results
################################################
printf "\nStep 9: Parse results"
if [ $inst_rf == "all" ] ; then
    python parse_results.py inst_address
    python parse_results.py inst_value
    python parse_results.py rf
else
    python parse_results.py $inst_rf
fi

