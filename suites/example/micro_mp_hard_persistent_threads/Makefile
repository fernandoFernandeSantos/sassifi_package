include ../common_env.mk

OPS?=1000000
LOGS=1
DEBUG?=0
FORJETSON=0
BUILDPROFILER=0

CC=g++
CUDAPATH=$(CUDA_BASE_DIR)


#ARCH+= 	-gencode arch=compute_62,code=[sm_62,compute_62]	# Titan V | Tesla V100
ARCH+= 	-gencode arch=compute_35,code=[sm_35,compute_35]	# Tesla k20

NVCC_FLAGS= $(ARCH) -Xptxas -v $(EXTRA_NVCC_FLAGS)  $(EXTRA_LINK_FLAGS)

NVIDIA_INC=$(CUDAPATH)/include/
NVIDIA_LIB=$(CUDAPATH)/lib64/
LOGHELPER_INC=../include/,/home/carol/radiation-benchmarks/src/cuda/common
LOGHELPER_LIB=../include/,/home/carol/radiation-benchmarks/src/cuda/common/lib

ifeq ($(BUILDPROFILER), 1)
NVCC_FLAGS+= -DBUILDPROFILER=1

ifeq ($(FORJETSON), 1)
NVCC_FLAGS += -DFORJETSON=1 -lJTX2Inst -li2c
else
NVCC_FLAGS += -L$(NVIDIA_LIB)/stubs -lnvidia-ml  -lNVMLWrapper
endif

endif


ifeq ($(DEBUG), 1)
OPS=1000
NVCC_FLAGS+= -g -G
endif

ifeq ($(LOGS), 1)
NVCC_FLAGS+= -DLOGS
FLAGS=-I$(LOGHELPER_INC) -L$(LOGHELPER_INC) 
endif

SOURCES=./cuda_micro.cu
EXEC=./cuda_micro_persistent_threads

FLAGS+=-I$(NVIDIA_INC) -I../common -L$(NVIDIA_LIB) -DOPS=$(OPS)
FLAGS+= -O3 -lLogHelper -std=c++11 -lcublas $(NVCC_FLAGS)

all: $(EXEC) install

$(EXEC): clean $(SOURCES)
	$(NVCC) $(FLAGS) -Xcompiler "-fopenmp -O3" $(SOURCES) -dc -o tmp.o
	$(NVCC) $(FLAGS) -Xcompiler "-fopenmp -O3" tmp.o -o $(EXEC)

install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(EXEC) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/

clean:
	rm -rf $(EXEC)

test:
	$(EXEC) --iterations 1 --precision single --redundancy none --inst fma

golden:
	$(EXEC) --iterations 1 --precision single --redundancy none --inst fma  > golden_stdout.txt 2>golden_stderr.txt


