include ../common_env.mk

CXX=g++-4.8 

CXXFLAGS= -std=c++11 -o3  -fPIC -pthread 
EXEC=cuda_lava

RAD_DIR=/home/carol/radiation-benchmarks

LOGS=1
BUILDPROFILER=0
OPERATIONNUM=1
PRECISION=double
DMR=dmrmixed
DATA_DIR=$(RAD_DIR)/data/lava
DEF_SIZE=23
STREAMS=1
CHARGES_INPUT=$(DATA_DIR)/lava_$(PRECISION)_charges_$(DEF_SIZE)
DISTANCES_INPUT=$(DATA_DIR)/lava_$(PRECISION)_distances_$(DEF_SIZE)
GOLD=$(DATA_DIR)/lava_$(PRECISION)_gold_$(DEF_SIZE)


VPATH=./src
CUDAPATH=/usr/local/sassi7
NVCC=$(CUDAPATH)/bin/nvcc
NVCCFLAGS= -std=c++11 -O3 -Xptxas -v 

ARCH= -gencode arch=compute_35,code=[sm_35,compute_35] #Kepler
#ARCH+= -gencode arch=compute_70,code=[sm_70,compute_70] #Titan V
#ARCH+= -gencode arch=compute_72,code=[sm_72,compute_72] #XavierV
#-I$(CUDAPATH)/samples/common/inc 
INCLUDE= -I./src -I$(CUDAPATH)/include -I$(RAD_DIR)/src/include -I$(RAD_DIR)/src/cuda/common

OBJDIR=./obj/
OBJ= setup_double.o  setup_float.o Parameters.o cuda_lava.o 

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


LDFLAGS+= -L$(CUDAPATH)/lib64  -lcudart  -lcurand

OBJS = $(addprefix $(OBJDIR), $(OBJ))
DEPS = $(wildcard src/*.h) Makefile


all: clean obj $(EXEC) install


$(EXEC): $(OBJS)  
	$(NVCC) --compiler-options "$(CFLAGS)" $^ -o $@ $(LDFLAGS) $(INCLUDE)  $(EXTRA_NVCC_FLAGS) $(EXTRA_LINK_FLAGS)

$(OBJDIR)%.o: %.cpp $(DEPS)
	$(CXX) $(CXXFLAGS) -c $< -o $@ $(INCLUDE)
	
$(OBJDIR)%.o: %.cu $(DEPS)
	$(NVCC) -ccbin $(CXX) $(ARCH) $(NVCCFLAGS) --compiler-options "-fPIC" -c $< -o $@ $(INCLUDE)   $(EXTRA_NVCC_FLAGS) $(EXTRA_LINK_FLAGS)

obj:
	mkdir -p $(OBJDIR)

clean:
	rm -f $(OBJDIR)* $(EXEC)
	
install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	
generate:
	./$(EXEC) -boxes $(DEF_SIZE) -generate -streams $(STREAMS) \
				-iterations 1 -verbose \
				-input_distances $(DISTANCES_INPUT) \
				-input_charges $(CHARGES_INPUT)	\
				-output_gold $(GOLD) \
				-opnum $(OPERATIONNUM) -precision $(PRECISION) \
				-redundancy none -opnum 1

test:
	./$(EXEC) -boxes $(DEF_SIZE) -streams $(STREAMS) \
				-iterations 1 -verbose \
				-input_distances $(DISTANCES_INPUT) \
				-input_charges $(CHARGES_INPUT) \
				-output_gold $(GOLD) \
				-opnum $(OPERATIONNUM) -precision $(PRECISION) \
				-redundancy ${DMR} -opnum $(OPERATIONNUM)
				

