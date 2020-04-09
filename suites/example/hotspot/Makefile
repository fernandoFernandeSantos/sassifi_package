include ../common_env.mk

PRECISION=-DPRECISION_SINGLE

TARGET = hotspot
LOG_FLAGS=-DLOGS -I/home/carol/radiation-benchmarks/src/cuda/common/include  -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelper

CXX=g++-4.8
NVCC_FLAGS = $(PRECISION) $(LOG_FLAGS) -ccbin $(CXX) -rdc=true -Xptxas -v -I$(CUDA_BASE_DIR)/include/ $(EXTRA_NVCC_FLAGS) -Xcompiler " -fopenmp"
LINK_FLAGS = -std=c++11 $(GENCODE) -lcudart -lcudadevrt $(EXTRA_LINK_FLAGS)


LD_LIB=LD_LIBRARY_PATH=/usr/local/sassi7/lib64/

all: clean $(TARGET) install

$(TARGET):
	$(NVCC) -o hotspot cuda_hotspot.cu $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)
	
hotspot_generate: 
	$(NVCC) -o hotspot hotspot.cu $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)
	
	
install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/

golden:
	./hotspot -size=1024 -sim_time=10000 -streams=1 -temp_file=temp_1024 -power_file=power_1024 -gold_file=gold_1024_1 -iterations=1 > golden_stdout.txt 2>golden_stderr.txt

test:
	./hotspot -size=1024 -sim_time=10000 -streams=1 -temp_file=temp_1024 -power_file=power_1024 -gold_file=gold_1024_1 -iterations=1

generate:
	./hotspot -size=1024 -sim_time=10000 -streams=1 -temp_file=temp_1024 -power_file=power_1024 -gold_file=gold_1024_1 -iterations=1 -generate

clean:
	rm -f *.o *~ hotspot

