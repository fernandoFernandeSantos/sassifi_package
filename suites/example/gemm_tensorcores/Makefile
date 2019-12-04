include ../common_env.mk


GPU?=1
DEBUG?=0
#for radiation setup
LOGS=1
OMP?=1
CHECKBLOCK=1

SIZE?=512 #6384 #8192 #4096 
ITERATIONS=1
DMR=mixed

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
LDFLAGS+= -L$(CUDAPATH)/lib64 -lcudart -lcurand
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

ALPHA=0.9
BETA=0.1

# GEMM options
generate:
	./$(TARGET) --size $(SIZE) --generate 1  --precision double --dmr none --alpha $(ALPHA) --beta $(BETA) \
			--input_a  /home/carol/SASSIFI/sassifi_package/suites/example/gemm_tensorcores/input_a.matrix  \
			--input_b  /home/carol/SASSIFI/sassifi_package/suites/example/gemm_tensorcores/input_b.matrix \
			--input_c  /home/carol/SASSIFI/sassifi_package/suites/example/gemm_tensorcores/input_c.matrix  \
			--gold /home/carol/SASSIFI/sassifi_package/suites/example/gemm_tensorcores/gold.matrix
			
golden:
	./$(TARGET) --size $(SIZE) --generate 1  --precision double --dmr $(DMR) --alpha $(ALPHA) --beta $(BETA) --opnum $(CHECKBLOCK) \
			--input_a  /home/carol/SASSIFI/sassifi_package/suites/example/gemm_tensorcores/input_a.matrix  \
			--input_b  /home/carol/SASSIFI/sassifi_package/suites/example/gemm_tensorcores/input_b.matrix \
			--input_c  /home/carol/SASSIFI/sassifi_package/suites/example/gemm_tensorcores/input_c.matrix  \
			--gold /home/carol/SASSIFI/sassifi_package/suites/example/gemm_tensorcores/gold.matrix  > golden_stdout.txt 2>golden_stderr.txt
	
test_gemm_dmr_mixed:
	./$(TARGET) --size $(SIZE) --generate 0  --precision double --dmr $(DMR) --iterations $(ITERATIONS)

test:
	./$(TARGET) --size $(SIZE) --generate 0  --precision double --dmr $(DMR) --iterations $(ITERATIONS) --alpha $(ALPHA) --beta $(BETA) --opnum $(CHECKBLOCK) \
			--input_a  /home/carol/SASSIFI/sassifi_package/suites/example/gemm_tensorcores/input_a.matrix  \
			--input_b  /home/carol/SASSIFI/sassifi_package/suites/example/gemm_tensorcores/input_b.matrix \
			--input_c  /home/carol/SASSIFI/sassifi_package/suites/example/gemm_tensorcores/input_c.matrix  \
			--gold /home/carol/SASSIFI/sassifi_package/suites/example/gemm_tensorcores/gold.matrix
	
test_gemm_non_dmr:
	./$(TARGET) --size $(SIZE) --generate 0 --verbose 1 --precision double --dmr none --iterations $(ITERATIONS)


# Tensor options
generate_tensor:
	./$(TARGET) --size $(SIZE) --generate 1 --verbose 1 --precision half --dmr none --tensor_cores 1

test_tensor_non_dmr:
	./$(TARGET) --size $(SIZE) --generate 0 --verbose 1 --precision half --dmr none --tensor_cores 1 --iterations $(ITERATIONS)
	
test_tensor_dmr:
	./$(TARGET) --size $(SIZE) --generate 0 --verbose 1 --precision half --dmr mixed --tensor_cores 1 --iterations $(ITERATIONS)
	
	
install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
