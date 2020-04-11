include ../common_env.mk


GPU?=1
DEBUG?=0
#for radiation setup
LOGS=1
OMP?=1

ALPHA=1.0
BETA=0.0
SIZE?=256
ITERATIONS=1
PRECISION=float
CUBLAS=0
TENSOR_CORES=0
DMR=none
BUILDRELATIVEERROR=0
CHECKBLOCK=1

OUTPUTPREFIX=$(PRECISION)_$(ALPHA)_$(BETA)_$(SIZE)_cublas_$(CUBLAS)_tensor_$(TENSOR_CORES).matrix

# This is what I use, uncomment if you know your arch and want to specify
ARCH= 	-gencode arch=compute_35,code=[sm_35,compute_35]		# Kepler
#ARCH+= 	-gencode arch=compute_61,code=[sm_61,compute_61]	# Titan X | Titan Xp
#ARCH+= 	-gencode arch=compute_62,code=[sm_62,compute_62]	# Tegra X2
#ARCH+= 	-gencode arch=compute_70,code=[sm_70,compute_70]	# Titan V | Tesla V100

VPATH=./src/
TARGET=gemm
OBJDIR=./obj/

CXX=g++-4.8 
#g++
CUDAPATH=$(CUDA_BASE_DIR)
#/usr/local/cuda-7.0
NVCC=$(CUDAPATH)/bin/nvcc 
OPTS=-O3
LDFLAGS= -lm -lstdc++ 
COMMON= 
CFLAGS=-Wall -Wfatal-errors  -Wunknown-pragmas -Wunused-function
RAD_DIR=/home/carol/radiation-benchmarks

INCLUDE=-I$(CUDAPATH)/include -I/home/carol/radiation-benchmarks/src/cuda/common

ifeq ($(DEBUG), 1) 
OPTS=-O0 -g -DDEBUG
NVCCFLAGS+= -g -G -DDEBUG
endif

CFLAGS+=$(OPTS) -fPIC
STDVERSION=--std=c++11

COMMON+= $(STDVERSION)

ifeq ($(GPU), 1) 
COMMON+= -DGPU -I$(CUDAPATH)/include/
CFLAGS+= -DGPU
LDFLAGS+= -L$(CUDAPATH)/lib64 -lcudart -lcurand -lcublas
endif

ifeq ($(OMP), 1) 
CFLAGS+= -DOMP -fopenmp
endif


OBJ= main.o setup_gemm.o Log.o common.o #setup_tensor_cores.o

ifeq ($(LOGS), 1)
INCLUDE+=-I../include/
NVCCFLAGS+= -DLOGS
CFLAGS+= -DLOGS
LDFLAGS+= -L../include/ -lLogHelper -DLOGS=1
endif

OBJS = $(addprefix $(OBJDIR), $(OBJ))
DEPS = $(wildcard src/*.h) Makefile

NVCCFLAGS+= -Xptxas -v -rdc=true

all: clean obj $(TARGET) install

$(TARGET): $(OBJS)
	$(NVCC) $(ARCH) $(COMMON) --compiler-options "$(CFLAGS)" $^ $(INCLUDE) -o $@  $(LDFLAGS)   $(EXTRA_NVCC_FLAGS) $(EXTRA_LINK_FLAGS)

$(OBJDIR)%.o: %.cpp $(DEPS)
	$(CXX) $(COMMON) $(CFLAGS) -c $< -o $@ $(INCLUDE) 

$(OBJDIR)%.o: %.cu $(DEPS)
	$(NVCC) -ccbin $(CXX) $(ARCH) $(COMMON) $(NVCCFLAGS) --compiler-options "$(CFLAGS)" $(INCLUDE) -c $< -o $@ $(EXTRA_NVCC_FLAGS) $(EXTRA_LINK_FLAGS)


obj:
	mkdir -p obj


.PHONY: clean
clean:
	rm -rf $(OBJS) $(TARGET)

DIR=/home/carol/SASSIFI/sassifi_package/suites/example/gemm_tensorcores


# GEMM options
generate:
	./$(TARGET) --size $(SIZE) --generate --verbose \
                        --precision $(PRECISION) --dmr none \
                        --alpha $(ALPHA) --beta $(BETA) \
                        --input_a $(DIR)/a_$(OUTPUTPREFIX) \
                        --input_b $(DIR)/b_$(OUTPUTPREFIX) \
                        --input_c $(DIR)/c_$(OUTPUTPREFIX) \
                        --gold $(DIR)/g_$(OUTPUTPREFIX) $(USECUBLAS) $(USETENSORS)

test:
	./$(TARGET) --size $(SIZE) --verbose \
                        --precision $(PRECISION) --dmr $(DMR) \
                        --iterations $(ITERATIONS)  \
                        --alpha $(ALPHA) --beta $(BETA) \
                        --input_a $(DIR)/a_$(OUTPUTPREFIX) \
                        --input_b $(DIR)/b_$(OUTPUTPREFIX) \
                        --input_c $(DIR)/c_$(OUTPUTPREFIX) \
                        --gold  $(DIR)/g_$(OUTPUTPREFIX)       \
                        --opnum $(CHECKBLOCK) $(USECUBLAS) $(USETENSORS)


golden:
	./$(TARGET) --size $(SIZE) --verbose \
                        --precision $(PRECISION) --dmr $(DMR) \
                        --iterations $(ITERATIONS)  \
                        --alpha $(ALPHA) --beta $(BETA) \
                        --input_a $(DIR)/a_$(OUTPUTPREFIX) \
                        --input_b $(DIR)/b_$(OUTPUTPREFIX) \
                        --input_c $(DIR)/c_$(OUTPUTPREFIX) \
                        --gold  $(DIR)/g_$(OUTPUTPREFIX)       \
                        --opnum $(CHECKBLOCK) $(USECUBLAS) $(USETENSORS) > golden_stdout.txt 2>golden_stderr.txt

install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
