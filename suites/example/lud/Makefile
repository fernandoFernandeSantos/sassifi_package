include ../common_env.mk

CXX=g++-4.8
COMMON= -std=c++11 -O3 
CXXFLAGS= -fPIC -fopenmp 
EXEC=cudaLUD
LOGS=1
BUILDPROFILER=0
ITERATIONS=10
SIZE=8192

VPATH=./src/
CUDAPATH=$(CUDA_BASE_DIR)
NVCC=$(CUDAPATH)/bin/nvcc

NVCCFLAGS= -Xptxas -v -rdc=true --compiler-options "$(CXXFLAGS)" 

ARCH= -gencode arch=compute_35,code=[sm_35,compute_35] #Kepler
#ARCH+= -gencode arch=compute_70,code=[sm_70,compute_70] #Titan V

INCLUDE= -I./src -I$(CUDAPATH)/include -I$(CUDAPATH)/samples/common/inc -I../include -I/home/carol/radiation-benchmarks/src/cuda/common/include

OBJDIR=./obj/
OBJ=  lud_kernel.o  main.o Parameters.o

ifeq ($(DEBUG), 1) 
CXXFLAGS+=-O0 -g
NVCCFLAGS+= -g -G
endif

ifeq ($(LOGS), 1)
CXXFLAGS+= -DLOGS
NVCCFLAGS+= -DLOGS
LDFLAGS+= -L../include  -lLogHelper
endif

LDFLAGS+= -L$(CUDAPATH)/lib64  -lcudart  -lcurand $(EXTRA_LINK_FLAGS)
NVCCFLAGS+= -ccbin $(CXX) $(EXTRA_NVCC_FLAGS) 

OBJS = $(addprefix $(OBJDIR), $(OBJ))
DEPS = $(wildcard src/*.h) Makefile


all: clean mkdir $(EXEC) install


$(EXEC): $(OBJS)  
	$(NVCC) $(ARCH) $(COMMON) $^ -o $@ $(NVCCFLAGS) $(LDFLAGS) $(INCLUDE)

$(OBJDIR)%.o: %.cpp $(DEPS)
	$(CXX) $(COMMON) $(CXXFLAGS) -c $< -o $@ $(INCLUDE)
	
$(OBJDIR)%.o: %.cu $(DEPS)
	$(NVCC) $(COMMON) $(ARCH) $(NVCCFLAGS) -c $< -o $@ $(INCLUDE) 

mkdir:
	mkdir -p $(OBJDIR)

clean:
	rm -f $(OBJDIR)* $(EXEC)
	

generate:
	./$(EXEC) --size $(SIZE) --generate --input ./input_$(SIZE).data --gold ./gold_$(SIZE).data --iterations $(ITERATIONS) --verbose;

test:
	./$(EXEC) --size $(SIZE) --input ./input_$(SIZE).data --gold ./gold_$(SIZE).data --iterations $(ITERATIONS) --verbose;

install: $(EXEC)
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(EXEC) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
