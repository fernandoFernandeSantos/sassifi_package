include ../common_env.mk
TARGET = leNetCUDA

VPATH=./src/
OBJDIR=./obj/

SRC=./src/
#~ NVCC=nvcc
CXX=g++

OBJDIR=./obj/

GPU?=1
LOGS?=0

#~ ARCH= -gencode arch=compute_35,code=[sm_35,compute_35] \
      #~ -gencode arch=compute_50,code=[sm_50,compute_50] \
      #~ -gencode arch=compute_52,code=[sm_52,compute_52] \
      #~ -gencode arch=compute_60,code=[sm_60,compute_60] \
      #~ -gencode arch=compute_62,code=[sm_62,compute_62]

#for radiation setup
LOGS?=0
COMMON=-std=c++11


CFLAGS= $(COMMON)

NVCC_FLAGS= -Xcompiler -Ofast
#-std=c++11

ifeq ($(DEBUG),1)
OPTS= -g
endif

ifeq ($(LOGS), 1)
LOGHELPERINC=-I../../include/
LOGHELPERLIB=-L../../include/ -lLogHelper
CFLAGS+= -DLOGS
endif

ifeq ($(GPU), 1)
ON_GPU= -DGPU
CFLAGS+=  -I/usr/local/sassi7/include -L/usr/local/sassi7/lib64 -lcuda -lcudart
	ifeq ($(DEBUG),1)
	NVCC_FLAGS+= -G
	endif

endif

OBJ=Layer.o ConvolutionalLayer.o MaxpoolingLayer.o FullyConnectedLayer.o \
OutputLayer.o ConvNet.o MNISTParser.o Util.o main.o LogsProcessing.o

ifeq ($(GPU), 1)
OBJ+= ConvolutionalLayerKernel.o MaxpoolingLayerKernel.o \
FullyConnectedLayerKernel.o  OutputLayerKernel.o cudaUtil.o
endif

OBJS = $(addprefix $(OBJDIR), $(OBJ))
DEPS = $(wildcard src/*.h) Makefile

############################################################################################
#-------------------------------------------------------------------------------------------
#-rdc=true
NVCC_FLAGS += -rdc=true  -Xptxas -v -I$(CUDA_BASE_DIR)/include/ $(EXTRA_NVCC_FLAGS) $(GENCODE) --compiler-options -Wall -Wextras
LINK_FLAGS =  -lcudart -lcudadevrt $(EXTRA_LINK_FLAGS)

LD_LIB=LD_LIBRARY_PATH=/usr/local/sassi7/lib64/

ALL_FLAGS=$(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)
#-------------------------------------------------------------------------------------------
############################################################################################

all: clean $(TARGET) install

$(TARGET): $(OBJS)
	$(NVCC) $^ $(ON_GPU) -o $@  $(CFLAGS) $(LDFLAGS) $(LOGHELPERINC) $(LOGHELPERLIB) $(ALL_FLAGS)

$(OBJDIR)%.o: %.cpp $(DEPS)
	$(CXX) $(OPTS) $(ON_GPU) -c $< -o $@  $(HELPFUL) $(LOGHELPERINC) $(LOGHELPERLIB) $(CFLAGS)

$(OBJDIR)%.o: %.cu $(DEPS)
	$(NVCC) $(ARCH) $(COMMON) $(OPTS) -c $< -o $@ $(ALL_FLAGS)

DATA_DIR=/home/carol/radiation-benchmarks/data/lenet

debug:
	#$(NVCC) $(ARCH) $(COMMON) $(OPTS) src/debug.cu -o debug
	$(CXX) $(COMMON) $(OPTS) src/compare_layers.cpp -o compare


#usage: ./leNetCUDA <train\classify\gold_gen\rad_test> <dataset> <labels> <weights>
#[gold input/output] [sample_count] [save layers] [iterations]
train:
	./$(EXEC) train $(DATA_DIR)/train-images-idx3-ubyte $(DATA_DIR)/train-labels-idx1-ubyte $(DATA_DIR)/lenet_base.weights

train_l1:
	./$(EXEC) train $(DATA_DIR)/train-images-idx3-ubyte $(DATA_DIR)/train-labels-idx1-ubyte $(DATA_DIR)/lenet_L1.weights L1

train_l2:
	./$(EXEC) train $(DATA_DIR)/train-images-idx3-ubyte $(DATA_DIR)/train-labels-idx1-ubyte ./lenet_L2.weights L2

test:
	./$(EXEC) rad_test $(DATA_DIR)/t10k-images-idx3-ubyte $(DATA_DIR)/t10k-labels-idx1-ubyte \
	$(DATA_DIR)/lenet_base.weights $(DATA_DIR)/gold_test 2 1 1


generate:
	./$(EXEC) gold_gen $(DATA_DIR)/t10k-images-idx3-ubyte $(DATA_DIR)/t10k-labels-idx1-ubyte \
	 $(DATA_DIR)/lenet_base.weights $(DATA_DIR)/gold_test 2 1 1


golden:
	./$(EXEC) rad_test $(DATA_DIR)/t10k-images-idx3-ubyte $(DATA_DIR)/t10k-labels-idx1-ubyte \
	$(DATA_DIR)/lenet_base.weights $(DATA_DIR)/gold_test 2 1 1 > golden_stdout.txt 2>golden_stderr.txt


download_input:
	wget http://yann.lecun.com/exdb/mnist/train-images-idx3-ubyte.gz
	wget http://yann.lecun.com/exdb/mnist/train-labels-idx1-ubyte.gz
	wget http://yann.lecun.com/exdb/mnist/t10k-images-idx3-ubyte.gz
	wget http://yann.lecun.com/exdb/mnist/t10k-labels-idx1-ubyte.gz
	gunzip train-images-idx3-ubyte.gz
	gunzip train-labels-idx1-ubyte.gz
	gunzip t10k-images-idx3-ubyte.gz
	gunzip t10k-labels-idx1-ubyte.gz


install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/


obj:
	mkdir -p obj

.PHONY: clean
clean:
	rm -rf obj/*o $(TARGET) debug compare
