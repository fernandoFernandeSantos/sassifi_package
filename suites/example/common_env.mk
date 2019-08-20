#Makefile common rules for all radiation-benchmarks
#Created by Fernando

#this is for our log helper library
LOGS?=0

#sassifi default variables
SUITE_NAME = example
OPTION = none

#gencode must be set to compute arch and sm
GENCODE = -gencode arch=compute_35,code=sm_35 -gencode arch=compute_50,code=sm_50

# INST_LIB_DIR is where instlibs dir is located
INST_LIB_DIR = $(SASSI_SRC)/instlibs/lib
#/home/carol/SASSIFI/SASSI/instlibs/lib/

#REGRESSION_HOME is where sassifi_package is located
REGRESSION_HOME =  $(SASSIFI_HOME)
#/home/carol/SASSIFI/sassifi_package/

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
CXXFLAGS = -O3 -D_FORCE_INLINES 
export CCDIR = /usr/bin/gcc-4.9
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
EXTRA_LINK_FLAGS =  -L$(INST_LIB_DIR) -lprofiler $(CUPTI)
endif

ifeq (${OPTION},inst_value_injector)
EXTRA_NVCC_FLAGS = $(AFTER_REG_MEM) $(AFTER_REG_MEM_INFO) $(BRANCH_AROUND)
EXTRA_LINK_FLAGS =  -L$(INST_LIB_DIR) -linstvalueinjector $(CUPTI)
endif

ifeq (${OPTION},inst_address_injector)
EXTRA_NVCC_FLAGS = $(AFTER_REG_MEM) $(AFTER_REG_MEM_INFO) $(BRANCH_AROUND) $(BEFORE_REG_MEM) $(BEFORE_REG_MEM_INFO)
EXTRA_LINK_FLAGS =  -L$(INST_LIB_DIR) -linstaddressinjector $(CUPTI)
endif

ifeq (${OPTION},rf_injector)
EXTRA_NVCC_FLAGS = $(BEFORE_ALL) $(BEFORE_REG_MEM_INFO)
EXTRA_LINK_FLAGS =  -L$(INST_LIB_DIR) -lrfinjector $(CUPTI)
endif


# to activate our log helper library
ifeq (${LOGS}, 1)
LOG_FLAGS=-DLOGS=1
endif

LOGHELPER_INC=../include
LOGHELPER_LIB=../include

#EXTRA_NVCC_FLAGS+=-D_FORCE_INLINES
