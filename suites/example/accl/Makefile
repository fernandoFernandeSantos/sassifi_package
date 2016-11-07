TARGET = accl
SUITE_NAME = example

OUTPUT=accl

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
export CCDIR = /usr/local/gcc-4.8.4/
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

#-----------------------------------------------------------------------
#from accl makefile 
SOURCEDIR = .
CPP_SOURCES = $(SOURCEDIR)/accl_main.cpp
CU_SOURCES = $(SOURCEDIR)/accl.cu
EXE = $(SOURCEDIR)/accl

DEVICE_OBJS = $(SOURCEDIR)/accl_cu.o
NVCCFLAGS = -pg
LINK_OBJS = $(SOURCEDIR)/accl_cu_dlink.o
#-----------------------------------------------------------------------


#NVCC_FLAGS = -O3 -g -rdc=true -Xptxas -v
#LINK_FLAGS = -std=c++11 -g -lcudart -lcudadevrt -lm 
NVCC_FLAGS =  $(logs) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda -rdc=true -Xptxas -v -I$(CUDA_BASE_DIR)/include/ $(EXTRA_NVCC_FLAGS) -Xcompiler " -fopenmp"
LINK_FLAGS = -std=c++11 $(GENCODE) -lcudart -lcudadevrt $(EXTRA_LINK_FLAGS)

LINE=$(DEVICE_OBJS) $(LINK_OBJS) $(CPP_SOURCES) ../include/log_helper.c -I$(LOGHELPER_INC) -L/usr/local/cuda/lib64 -lcudart -lcuda -lcudadevrt -lpthread -fopenmp

all: clean $(TARGET) install

#$(TARGET): accl_cu_dlink.o
#	$(CXX) -o $(OUTPUT)  accl_cu_dlink.o $(LINE)

install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/

test:

accl: accl_cu_dlink.o $(CPP_SOURCES)
	$(CXX) -o $(EXE) $(DEVICE_OBJS) $(LINK_OBJS) $(CPP_SOURCES) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda -L/usr/local/cuda/lib64 -lcudart \
	 -lcudadevrt -lpthread -fopenmp \
	 $(logs) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda -dc -std=c++11 $(EXTRA_LINK_FLAGS)

accl_generate: accl_cu_dlink.o accl_generate.cpp
	$(CXX) -o accl_generate $(DEVICE_OBJS) $(LINK_OBJS) accl_generate.cpp $(LOGHELPER_INC)log_helper.c -L/usr/local/cuda/lib64 -lcudart -lcudadevrt -lpthread -fopenmp  -std=c++11 -lcudart -lcudadevrt $(EXTRA_LINK_FLAGS)

accl_cu_dlink.o: accl_cu.o
	$(NVCC) $(NVCCFLAGS) $(GENCODE) -Xcompiler '-fPIC' -dlink $(DEVICE_OBJS) -o $(LINK_OBJS) -lcudadevrt $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)

accl_cu.o: $(CU_SOURCES)
	$(NVCC) $(NVCCFLAGS) $(GENCODE) -Xcompiler '-fPIC' -dc -m64 $(CU_SOURCES) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda  -o $(DEVICE_OBJS) \
	$(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)	

generate:
	./accl_generate 2 1 2Frames.pgm GOLD_2Frames

test: accl
	./accl 2 1 2Frames.pgm GOLD_2Frames 1 -verbose

golden: accl
	./accl 2 1 2Frames.pgm GOLD_2Frames 1 -verbose > golden_stdout.txt 2> golden_stderr.txt
	
clean:
	rm -f $(DEVICE_OBJS)
	rm -f $(LINK_OBJS)
	rm -f $(EXE) accl_generate
	rm -f accl
