########################################################################
#sassifi
TARGET = darknet
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
export CCDIR = /usr/local/gcc-4.8.4/
export PATH := $(CCDIR)/bin/:$(PATH)
export LD_LIBRARY_PATH := $(CCDIR)/lib64:$(LD_LIBRARY_PATH):$(CUDA_LIB_DIR):$(CUPTI_LIB_DIR)

AFTER_REG = -Xptxas --sassi-inst-after="reg-writes" 
AFTER_MEM = -Xptxas --sassi-inst-after="memory" 
AFTER_REG_MEM = -Xptxas --sassi-inst-after="reg-writes\,memory" 
BEFORE_ALL = -Xptxas --sassi-inst-before="all"
BEFORE_COND_BRANCHES = -Xptxas --sassi-inst-before="cond-branches"
BEFORE_MEM = -Xptxas --sassi-inst-before="memory"
BEFORE_REGS = -Xptxas --sassi-inst-before="reg-writes\,reg-reads"

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
NVCC_FLAGS =  $(logs) -I$(LOGHELPER_INC) -rdc=true -Xptxas -v -I$(CUDA_BASE_DIR)/include/ $(EXTRA_NVCC_FLAGS) -Xcompiler " -fopenmp" -D_FORCE_INLINES
LINK_FLAGS = -std=c++11 $(GENCODE) -lcudart -lcudadevrt $(EXTRA_LINK_FLAGS)


########################################################################
GPU?=1
CUDNN?=0
OPENCV?=0
DEBUG?=0
LOGS?=1
#ARCH_I?=35

ARCH= -gencode arch=compute_35,code=sm_35 
#-gencode arch=compute_50,code=sm_50 \
  #    -gencode arch=compute_53,code=sm_53 -gencode=arch=compute_60,code=sm_60 \
  #    -gencode=arch=compute_61,code=sm_61 -gencode=arch=compute_62,code=sm_62
#--gpu-architecture=compute_$(ARCH_I) --gpu-code=compute_$(ARCH_I)

VPATH=./src/
EXEC=darknet
OBJDIR=./obj/
LOGHELPER_INC=../include/
LOGHELPER_LIB=../include/

CC=gcc
#NVCC=/usr/local/cuda/bin/nvcc
OPTS= -Xcompiler "-Ofast"
LDFLAGS= -Xcompiler "-lm -pthread"
COMMON=
CFLAGS= -Xcompiler "-Wall -Wfatal-errors" -Wno-deprecated-gpu-targets

CUDAINCLUDE=/usr/local/sassi7/include/

ifeq ($(DEBUG), 1)
	OPTS=-O0 -g
endif

CFLAGS+=$(OPTS)

ifeq ($(OPENCV), 1)
	COMMON+= -DOPENCV
	CFLAGS+= -DOPENCV
	LDFLAGS+= `pkg-config --libs opencv`
	COMMON+= `pkg-config --cflags opencv`
endif

ifeq ($(GPU), 1)
	COMMON+= -DGPU -I/usr/local/sassi7/include/
	CFLAGS+= -Xcompiler "-DGPU"
	LDFLAGS+= -L/usr/local/sassi7/lib64 -lcuda -lcudart -lcublas -lcurand
endif

ifeq ($(CUDNN), 1)
	COMMON+= -DCUDNN
	CFLAGS+= -DCUDNN
	LDFLAGS+= -lcudnn
endif

ifeq ($(LOGS), 1)
	CFLAGS+=-I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -DLOGS=1 
	#LOG_LINK= -Xcompiler "-I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda -DLOGS=1 " -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda -DLOGS=1
	#$(LOGHELPER_LIB)log_helper.o 
#	CFLAGS+= -DLOGS -Xcompiler "-I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda" -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda
endif

LOG_CU = $(LOGHELPER_LIB)log_helper.c


OBJ=gemm.o utils.o cuda.o deconvolutional_layer.o convolutional_layer.o list.o image.o activations.o \
	 im2col.o col2im.o blas.o crop_layer.o dropout_layer.o maxpool_layer.o softmax_layer.o data.o \
	 matrix.o network.o connected_layer.o cost_layer.o parser.o option_list.o darknet.o detection_layer.o \
	 captcha.o route_layer.o writing.o box.o nightmare.o normalization_layer.o avgpool_layer.o coco.o dice.o \
	 yolo.o detector.o layer.o compare.o classifier.o local_layer.o swag.o shortcut_layer.o activation_layer.o \
	 rnn_layer.o gru_layer.o rnn.o rnn_vid.o crnn_layer.o demo.o tag.o cifar.o go.o batchnorm_layer.o art.o \
	 region_layer.o reorg_layer.o super.o voxel.o args.o log_processing.o abft_host.o
	 
ifeq ($(GPU), 1)
LDFLAGS+= -lstdc++
OBJ+=convolutional_kernels.o deconvolutional_kernels.o activation_kernels.o im2col_kernels.o \
	col2im_kernels.o blas_kernels.o crop_layer_kernels.o dropout_layer_kernels.o maxpool_layer_kernels.o \
	softmax_layer_kernels.o network_kernels.o avgpool_layer_kernels.o abft.o maxpool_layer_hardened_kernels.o
endif


NVCCFLAGS= -Xcompiler "-L/usr/local/sassi7/lib64 -lcuda -lcurand  -lcudart" -Xcompiler '-fPIC' -Xcompiler '-lm' -D_FORCE_INLINES

OBJS = $(addprefix $(OBJDIR), $(OBJ))
DEPS = $(wildcard src/*.h) Makefile

all: clean  $(TARGET) install

$(TARGET): $(OBJS) 
	$(NVCC) $(COMMON) $(BUILD_ABFT_OBJ) $^  -o $@  -lcudadevrt -lcudart -lcuda $(LDFLAGS) $(CFLAGS)  $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)
	
$(OBJDIR)%.o: %.c $(DEPS) 
	$(NVCC) $(COMMON) $(CFLAGS) -c $< -o $@ $(LDFLAGS) $(CFLAGS) $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)

$(OBJDIR)%.o: %.cpp $(DEPS) 
	$(NVCC) $(COMMON) $(CFLAGS) -c $< -o $@ $(LDFLAGS) $(CFLAGS) -I../../include/ $(CXXFLAGS) -std=c++11


$(OBJDIR)%.o: %.cu $(DEPS) $(BUILD_ABFT)
	$(NVCC) $(ARCH) $(COMMON) $(CFLAGS) -c $< -o $@  $(LDFLAGS) $(CFLAGS) $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)


.PHONY: clean

test:
	./darknet -a 0 -c /home/carol/radiation-benchmarks/data/darknet/yolo.cfg -b /home/carol/SASSIFI/sassifi_package/suites/example/darknet -e yolo -d /home/carol/radiation-benchmarks/data/darknet/gold.caltech.critical.abft.1K.test -m valid -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.critical.1K.txt -n 100 -s 1 -w /home/carol/radiation-benchmarks/data/darknet/yolo.weights  -x 0

generate:
	./darknet  -a 0 -c /home/carol/radiation-benchmarks/data/darknet/yolo.cfg -b /home/carol/SASSIFI/sassifi_package/suites/example/darknet -e yolo -g /home/carol/radiation-benchmarks/data/darknet/gold.caltech.critical.abft.1K.test -m valid -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.critical.1K.txt -n 1  -s 0 -w /home/carol/radiation-benchmarks/data/darknet/yolo.weights  -x 0

golden:
	./darknet -a 0 -c /home/carol/radiation-benchmarks/data/darknet/yolo.cfg -b /home/carol/SASSIFI/sassifi_package/suites/example/darknet -e yolo -d /home/carol/radiation-benchmarks/data/darknet/gold.caltech.critical.abft.1K.test -m valid -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.critical.1K.txt -n 1 -s 0 -w /home/carol/radiation-benchmarks/data/darknet/yolo.weights  -x 0 > golden_stdout.txt 2>golden_stderr.txt
	


install: $(TARGET)
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/

clean:
	rm -rf $(OBJS) $(EXEC) obj/*.o

