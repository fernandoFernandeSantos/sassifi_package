include ../common_env.mk

CXX=g++-4.8
CXXFLAGS= -std=c++11 -o3 -fopenmp 
TARGET=nw
LOGS=1
BUILDPROFILER=0
ITERATIONS=1

GPU?=1
DEBUG?=0
#for radiation setup
OMP?=1

SIZE?=16384
#6384 #8192 #4096 
ITERATIONS=1
INPUT=./input_$(SIZE)
GOLD=./gold_$(SIZE)
PENALTY=10

VPATH=./src/

CUDAPATH=$(CUDA_BASE_DIR)
NVCC=$(CUDAPATH)/bin/nvcc 

NVCCFLAGS= -std=c++11 -O3 -Xptxas -v  -Wno-deprecated-gpu-targets -rdc=true


ARCH= -gencode arch=compute_35,code=[sm_35,compute_35] #Kepler
#ARCH+= -gencode arch=compute_70,code=[sm_70,compute_70] #Titan V

INCLUDE= -I./src -I$(CUDAPATH)/include -I$(CUDAPATH)/samples/common/inc -I../include -I/home/carol/radiation-benchmarks/src/cuda/common

OBJDIR=./obj/
OBJ= needle.o needle_kernel.o

ifeq ($(DEBUG), 1) 
CXXFLAGS+=-O0 -g
NVCCFLAGS+= -g -G
endif

ifeq ($(LOGS), 1)
CXXFLAGS+= -DLOGS
NVCCFLAGS+= -DLOGS
LDFLAGS+= -L../include  -lLogHelper
endif

ifeq ($(BUILDPROFILER), 1)
CXXFLAGS+= -DBUILDPROFILER
LDFLAGS+= -L../common/lib -lNVMLWrapper -L$(CUDAPATH)/lib64/stubs -lnvidia-ml 
endif


LDFLAGS+= -L$(CUDAPATH)/lib64  -lcudart  -lcurand -lcudadevrt  -Wno-deprecated-gpu-targets

OBJS = $(addprefix $(OBJDIR), $(OBJ))
DEPS = $(wildcard src/*.h) Makefile


all: clean mkdir $(TARGET) install


$(TARGET): $(OBJS)  
	$(NVCC) -ccbin $(CXX)  --compiler-options  "$(CXXFLAGS)" $^ -o $@ $(LDFLAGS) $(INCLUDE) $(NVCCFLAGS) $(EXTRA_LINK_FLAGS)

$(OBJDIR)%.o: %.cpp $(DEPS)
	$(CXX) $(CXXFLAGS) -c $< -o $@ $(INCLUDE) 

	
$(OBJDIR)%.o: %.cu $(DEPS)
	$(NVCC)   -ccbin $(CXX) $(ARCH) $(NVCCFLAGS) -c $< -o $@ $(INCLUDE)     $(EXTRA_NVCC_FLAGS) $(EXTRA_LINK_FLAGS)

mkdir:
	mkdir -p $(OBJDIR)

clean:
	rm -f $(OBJDIR)* $(TARGET)

install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/

generate:
	./$(TARGET) $(SIZE) $(PENALTY) $(INPUT) $(GOLD) $(ITERATIONS) 1

test:
	./$(TARGET) $(SIZE) $(PENALTY) $(INPUT) $(GOLD) $(ITERATIONS) 0

golden:
	./$(TARGET) $(SIZE) $(PENALTY) $(INPUT) $(GOLD) $(ITERATIONS) 0 > golden_stdout.txt 2>golden_stderr.txt
	sed -i '/kernel time/c\REPLACED.' golden_stdout.txt 
	sed -i '/LOGFILE/c\REPLACED.' golden_stdout.txt 
	sed -i '/read../c\REPLACED.' golden_stdout.txt 
