include ../common_env.mk

CXX=g++-4.8
CXXFLAGS= -std=c++11 -o3 -fopenmp 
EXEC=cudaBFS
LOGS=1
BUILDPROFILER=0
ITERATIONS=10
GOLD=/home/carol/radiation-benchmarks/gold.data
INPUT=/home/carol/radiation-benchmarks/data/bfs/graph1MW_6.txt

VPATH=./src/

CUDAPATH=$(CUDA_BASE_DIR)
NVCC=$(CUDAPATH)/bin/nvcc 

NVCCFLAGS= -std=c++11 -O3 -Xptxas -v  -Wno-deprecated-gpu-targets -rdc=true


ARCH= -gencode arch=compute_35,code=[sm_35,compute_35] #Kepler
#ARCH+= -gencode arch=compute_70,code=[sm_70,compute_70] #Titan V

INCLUDE= -I./src -I$(CUDAPATH)/include -I$(CUDAPATH)/samples/common/inc -I../include -I/home/carol/radiation-benchmarks/src/cuda/common/include

OBJDIR=./obj/
OBJ= bfs.o main.o Parameters.o kernel.o


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


all: clean mkdir $(EXEC) install


$(EXEC): $(OBJS)  
	$(NVCC) -ccbin $(CXX)  --compiler-options  "$(CXXFLAGS)" $^ -o $@ $(LDFLAGS) $(INCLUDE) $(NVCCFLAGS)

$(OBJDIR)%.o: %.cpp $(DEPS)
	$(CXX) $(CXXFLAGS) -c $< -o $@ $(INCLUDE) 

	
$(OBJDIR)%.o: %.cu $(DEPS)
	$(NVCC)   -ccbin $(CXX) $(ARCH) $(NVCCFLAGS) -c $< -o $@ $(INCLUDE)     $(EXTRA_NVCC_FLAGS) $(EXTRA_LINK_FLAGS)

mkdir:
	mkdir -p $(OBJDIR)

clean:
	rm -f $(OBJDIR)* $(EXEC)

install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(EXEC) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/

generate:
	./$(EXEC) --input $(INPUT) --gold $(GOLD) --iterations $(ITERATIONS) --verbose --generate
	
test:
	./$(EXEC) --input $(INPUT) --gold $(GOLD) --iterations $(ITERATIONS) --verbose

	
