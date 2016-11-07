TARGET = lava
SUITE_NAME = example

OPTION = none

GENCODE = -gencode arch=compute_35,code=sm_35
INST_LIB_DIR = /home/carol/SASSIFI/SASSI/instlibs/lib/
REGRESSION_HOME = /home/carol/SASSIFI/sassifi_package/

# SASSI/CUDA
CUDA_BASE_DIR = /usr/local/sassi7
CUDA_LIB_DIR = $(CUDA_BASE_DIR)/lib64
CUDA_BIN_DIR = $(CUDA_BASE_DIR)/bin
CUPTI_LIB_DIR = $(CUDA_BASE_DIR)/extras/CUPTI/lib64
CUPTI = -L$(CUPTI_LIB_DIR) -lcupti 
NVCC = $(CUDA_BIN_DIR)/nvcc

# The C/CPP compiler you want to use, and associated flags.
CC = gcc
CXX = g++
CFLAGS = -O3
CXXFLAGS = -O3
export CCDIR = /usr/bin/
export PATH := $(CCDIR)/bin/:$(PATH)
export LD_LIBRARY_PATH := $(CCDIR)/lib64:$(LD_LIBRARY_PATH):$(CUDA_LIB_DIR):$(CUPTI_LIB_DIR)

AFTER_REG = -Xptxas --sassi-inst-after="reg-writes" 
AFTER_MEM = -Xptxas --sassi-inst-after="memory" 
AFTER_REG_MEM = -Xptxas --sassi-inst-after="reg-writes\,memory" 
BEFORE_ALL = -Xptxas --sassi-inst-before="all"
BEFORE_COND_BRANCHES = -Xptxas --sassi-inst-before="cond-branches"
BEFORE_MEM = -Xptxas --sassi-inst-before="memory"
BEFORE_REGS = -Xptxas --sassi-inst-before="reg-writes,reg-reads"

AFTER_REG_INFO = -Xptxas --sassi-after-args="reg-info"
AFTER_MEM_INFO = -Xptxas --sassi-after-args="mem-info"
AFTER_REG_MEM_INFO = -Xptxas --sassi-after-args="reg-info\,mem-info"
BEFORE_COND_BRANCH_INFO = -Xptxas --sassi-before-args="cond-branch-info"
BEFORE_MEM_INFO = -Xptxas --sassi-before-args="mem-info"
BEFORE_REG_INFO = -Xptxas --sassi-before-args="reg-info"
BEFORE_REG_MEM_INFO = -Xptxas --sassi-before-args="reg-info\,mem-info"

BRANCH_AROUND = -Xptxas --sassi-iff-true-predicate-handler-call

ifeq (${OPTION},profiler)
EXTRA_NVCC_FLAGS = $(BEFORE_ALL) $(BEFORE_REG_MEM_INFO)
EXTRA_LINK_FLAGS = -L$(INST_LIB_DIR) -lprofiler $(CUPTI)
endif

ifeq (${OPTION},inst_injector)
EXTRA_NVCC_FLAGS = $(AFTER_REG_MEM) $(AFTER_REG_MEM_INFO) $(BRANCH_AROUND) 
EXTRA_LINK_FLAGS = -L$(INST_LIB_DIR) -linstinjector $(CUPTI)
endif
 
ifeq (${OPTION},rf_injector)
EXTRA_NVCC_FLAGS = $(BEFORE_ALL) $(BEFORE_REG_MEM_INFO) 
EXTRA_LINK_FLAGS = -L$(INST_LIB_DIR) -lrfinjector $(CUPTI)
endif

LOGHELPER_INC=../include/
LOGHELPER_LIB=../include/

#NVCC_FLAGS = -O3 -g -rdc=true -Xptxas -v
#LINK_FLAGS = -std=c++11 -g -lcudart -lcudadevrt -lm 
NVCC_FLAGS =  $(logs) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda -rdc=true -Xptxas -v -I$(CUDA_BASE_DIR)/include/ $(EXTRA_NVCC_FLAGS) -Xcompiler " -fopenmp"
LINK_FLAGS = -std=c++11 $(GENCODE) -I$(CUDA_LIB_DIR) -lcudart -lcudadevrt $(EXTRA_LINK_FLAGS)

all: clean $(TARGET) install

$(TARGET): 
	$(NVCC) -o lava lava.cu $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)

install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/

test:
	./lava -boxes=10 -input_distances=input_distances_10 -input_charges=input_charges_10 -output_gold=GOLD -iterations=1 -streams=1

golden:
	./lava -boxes=10 -input_distances=input_distances_10 -input_charges=input_charges_10 -output_gold=GOLD -iterations=1 -streams=1 > golden_stdout.txt 2> golden_stderr.txt

generate: ./lava
	./lava -boxes=10 -generate -output_gold=GOLD -iterations=1 -streams=1

clean:
	rm -f *.o *~ lava
