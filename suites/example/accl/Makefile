include ../common_env.mk

CXX=g++-4.8
CXXFLAGS= -std=c++11 -O3 
EXEC=cudaACCL
LOGS=1
BUILDPROFILER=0
ITERATIONS=10
SIZE=7
FRAMES=7
GOLD=/home/carol/radiation-benchmarks/data/accl/gold_$(SIZE)_$(FRAMES).data
#../gold_accl/gold_7_7 
INPUT=/home/carol/radiation-benchmarks/data/accl/7Frames.pgm

VPATH=./src/

CUDAPATH=$(CUDA_BASE_DIR)
NVCC=$(CUDAPATH)/bin/nvcc 

NVCCFLAGS= -std=c++11 -O3 -Xptxas -v -rdc=true -ccbin g++-4.8

ARCH= -gencode arch=compute_35,code=[sm_35,compute_35] #Kepler
#ARCH+= -gencode arch=compute_70,code=[sm_70,compute_70] #Titan V

INCLUDE= -I./src -I$(CUDAPATH)/include -I$(CUDAPATH)/samples/common/inc -I../include -I/home/carol/radiation-benchmarks/src/cuda/common/include

OBJDIR=./obj/
GPUOBJ= accl.o_dlink.o
OBJ= accl.o main.o Parameters.o


ifeq ($(DEBUG), 1) 
CXXFLAGS+=-O0 -g
NVCCFLAGS+= -g -G
endif

ifeq ($(LOGS), 1)
CXXFLAGS+= -DLOGS
NVCCFLAGS+= -DLOGS
LDFLAGS+= -L../include  -lLogHelper
endif


LDFLAGS+= -L$(CUDAPATH)/lib64  -lcudart  -lcurand -lcudadevrt  -Wno-deprecated-gpu-targets

OBJS = $(addprefix $(OBJDIR), $(OBJ))
GPUOBJS = $(addprefix $(OBJDIR), $(GPUOBJ))
DEPS = $(wildcard src/*.h) Makefile


all: clean mkdir $(EXEC) install

install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(EXEC) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/

$(EXEC): $(OBJS)  
	$(NVCC)  $(NVCCFLAGS)  $^ -o $@ $(LDFLAGS) $(INCLUDE)
#	$(NVCC) $(CXXFLAGS) $(GPUOBJS) $^ -o $@ $(LDFLAGS) $(INCLUDE)

$(OBJDIR)%.o: %.cpp $(DEPS)
	$(CXX) $(CXXFLAGS) -c $< -o $@ $(INCLUDE)
	
$(OBJDIR)%.o: %.cu $(DEPS)
	$(NVCC)  $(ARCH) $(NVCCFLAGS) -c $< -o $@ $(INCLUDE)  $(EXTRA_LINK_FLAGS)   $(EXTRA_NVCC_FLAGS)
	#$(NVCC) $(ARCH)  -dlink $@ -o $@_dlink.o -lcudadevrt  $(EXTRA_LINK_FLAGS)   $(EXTRA_NVCC_FLAGS)

mkdir:
	mkdir -p $(OBJDIR)

clean:
	rm -f $(OBJDIR)* $(EXEC)
	

generate:
	./$(EXEC) --size $(SIZE) --frames $(FRAMES) --input $(INPUT) --gold $(GOLD) --iterations $(ITERATIONS) --verbose --generate ;

test:
	./$(EXEC) --size $(SIZE) --frames $(FRAMES) --input $(INPUT) --gold $(GOLD) --iterations $(ITERATIONS) --verbose;
	
