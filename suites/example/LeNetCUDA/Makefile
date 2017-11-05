#sassifi
include ../common_env.mk

VPATH=./src/
EXEC=leNetCUDA
OBJDIR=./obj/

SRC=./src/
NVCC=/usr/local/sassi7/bin/nvcc
CXX=g++

OBJDIR=./obj/

GPU?=0
LOGS?=0
TRAINGPU?=$(GPU)
NOTUSEUNIFIED?=$(GPU)

CUDA_THRUST=
#-I/usr/local/cuda/include/thrust/

#ARCH= -gencode arch=compute_35,code=[sm_35,compute_35] \
 #     -gencode arch=compute_50,code=[sm_50,compute_50] \
  #    -gencode arch=compute_52,code=[sm_52,compute_52] \
   #   -gencode arch=compute_60,code=[sm_60,compute_60] \
    #  -gencode arch=compute_62,code=[sm_62,compute_62]

#for radiation setup
LOGS?=0
COMMON=-std=c++11 


CFLAGS= $(COMMON) -O3
# -Xcompiler '-Wall -Wextra'

NVCC_FLAGS= -Xcompiler -O3 -Wno-deprecated-gpu-targets  -ccbin $(CXX)
#-std=c++11

ifeq ($(DEBUG),1)
OPTS= -g
endif

ifeq ($(LOGS), 1)
LOGHELPER_INC=-I../../include/
LOGHELPER_LIB=-L../../include/ -lLogHelper
CFLAGS+= -DLOGS
else
LOGHELPER_INC=
LOGHELPER_LIB=
endif


ifeq ($(GPU), 1)
ON_GPU= -DGPU
CFLAGS+=  -I/usr/local/sassi7/include -L/usr/local/sassi7//lib64 -lcudart -lcudadevrt
	ifeq ($(DEBUG),1)
		NVCC_FLAGS+= -G
	endif

	ifeq ($(NOTUSEUNIFIED), 1)
		NVCC_FLAGS+= -DNOTUNIFIEDMEMORY
		CFLAGS+= -DNOTUNIFIEDMEMORY
	endif
	
	ifeq ($(TRAINGPU), 1)
		NVCC_FLAGS+= -DTRAINGPU
		CFLAGS+= -DTRAINGPU
	endif
	
endif

GPU_KERNELS=ConvKernels.o

OBJ=Layer.o ConvolutionalLayer.o MaxpoolingLayer.o FullyConnectedLayer.o \
OutputLayer.o ConvNet.o MNISTParser.o Util.o main.o LogsProcessing.o

ifeq ($(GPU), 1)
OBJ+= ConvolutionalLayerKernel.o MaxpoolingLayerKernel.o \
FullyConnectedLayerKernel.o  OutputLayerKernel.o cudaUtil.o
endif

ifeq ($(DEBUG_LIGHT), 1)
CFLAGS+=-DDEBUG_LIGHT=1
NVCC_FLAGS+= -DDEBUG_LIGHT=1
endif

OBJS = $(addprefix $(OBJDIR), $(OBJ))
DEPS = $(wildcard src/*.h) Makefile


#-----------------------------------------------------------------------
#sassifi
NVCC_FLAGS +=  -rdc=true -Xptxas -v -I$(CUDA_BASE_DIR)/include/ $(EXTRA_NVCC_FLAGS)
LINK_FLAGS +=  $(GENCODE) -lcudart -lcudadevrt $(EXTRA_LINK_FLAGS)

NVCC_FLAGS += $(LINK_FLAGS)
TARGET=$(EXEC)
#-----------------------------------------------------------------------



DATA_DIR=/home/carol/radiation-benchmarks/data/lenet

all: clean obj $(EXEC) install

$(EXEC): $(OBJS)
	$(NVCC) $^  -o $@ $(ON_GPU)  $(CFLAGS) $(LDFLAGS) $(LOGHELPER_INC) $(LOGHELPER_LIB)  $(NVCC_FLAGS) 


$(OBJDIR)%.o: %.cpp $(DEPS)
	$(CXX) $(OPTS) -c $< -o $@ $(ON_GPU) $(HELPFUL) $(LOGHELPER_INC) $(LOGHELPER_LIB) $(CFLAGS) 

$(OBJDIR)%.o: %.cu $(DEPS)
	$(NVCC) $(ARCH) $(COMMON) $(OPTS) $(NVCC_FLAGS) -c $< -o $@



debug:
	#$(NVCC) $(ARCH) $(COMMON) $(OPTS) src/debug.cu -o debug
	$(CXX) $(COMMON) $(OPTS) src/compare_layers.cpp -o compare



#usage: ./leNetCUDA <train\classify\gold_gen\rad_test> <dataset> <labels> <weights>
#[gold input/output] [sample_count] [save layers] [iterations]

train:
	./$(EXEC) train $(DATA_DIR)/train-images-idx3-ubyte $(DATA_DIR)/train-labels-idx1-ubyte $(DATA_DIR)/lenet_base.weights

train_l1:
	./$(EXEC) train $(DATA_DIR)/train-images-idx3-ubyte $(DATA_DIR)/train-labels-idx1-ubyte $(DATA_DIR)/lenet_l1.weights L1

train_l2:
	./$(EXEC) train $(DATA_DIR)/train-images-idx3-ubyte $(DATA_DIR)/train-labels-idx1-ubyte $(DATA_DIR)/lenet_l2.weights L2

test_l1:
	./$(EXEC) classify $(DATA_DIR)/t10k-images-idx3-ubyte $(DATA_DIR)/t10k-labels-idx1-ubyte $(DATA_DIR)/lenet_l1.weights

test_l2:
	./$(EXEC) classify $(DATA_DIR)/t10k-images-idx3-ubyte $(DATA_DIR)/t10k-labels-idx1-ubyte $(DATA_DIR)/lenet_l2.weights


test:
	./$(EXEC) classify $(DATA_DIR)/t10k-images-idx3-ubyte $(DATA_DIR)/t10k-labels-idx1-ubyte $(DATA_DIR)/lenet_base.weights


generate:
	./$(EXEC) gold_gen $(DATA_DIR)/t10k-images-idx3-ubyte $(DATA_DIR)/t10k-labels-idx1-ubyte  $(DATA_DIR)/lenet_base.weights $(DATA_DIR)/gold_test 2 0 1

test_rad:
	./$(EXEC) rad_test $(DATA_DIR)/t10k-images-idx3-ubyte $(DATA_DIR)/t10k-labels-idx1-ubyte $(DATA_DIR)/lenet_base.weights $(DATA_DIR)/gold_test 2 0 1


LeNetCUDA_generate: all
LeNetCUDA: all



install: $(EXEC)
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/

download_input:
	wget http://yann.lecun.com/exdb/mnist/train-images-idx3-ubyte.gz
	wget http://yann.lecun.com/exdb/mnist/train-labels-idx1-ubyte.gz
	wget http://yann.lecun.com/exdb/mnist/t10k-images-idx3-ubyte.gz
	wget http://yann.lecun.com/exdb/mnist/t10k-labels-idx1-ubyte.gz
	gunzip train-images-idx3-ubyte.gz
	gunzip train-labels-idx1-ubyte.gz
	gunzip t10k-images-idx3-ubyte.gz
	gunzip t10k-labels-idx1-ubyte.gz



obj:
	mkdir -p obj

.PHONY: clean
clean:
	rm -rf obj/*o $(EXEC) debug compare
