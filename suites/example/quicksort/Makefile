include ../common_env.mk

TARGET = quicksort

#SIZE=134217728
SIZE=1048576 

RAD=/home/carol/radiation-benchmarks
LOG_FLAGS+= -DLOGS  -I$(RAD)/src/cuda/common


CXX=g++-4.8
NVCC_FLAGS = -ccbin $(CXX) $(LOG_FLAGS) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelper -rdc=true -Xptxas -v -I$(CUDA_BASE_DIR)/include/ $(EXTRA_NVCC_FLAGS) -Xcompiler " -fopenmp"
LINK_FLAGS = -std=c++11 $(GENCODE) -lcudart -lcudadevrt $(EXTRA_LINK_FLAGS)

all: clean $(TARGET) install

$(TARGET):
	$(NVCC) -o $(TARGET) cdpAdvancedQuicksort.cu cdpBitonicSort.cu  $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)

install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/

golden:
	./quicksort -size=$(SIZE) -input=quicksort_input_134217728 -gold=quicksort_gold_$(SIZE) -iterations=1 > golden_stdout.txt 2>golden_stderr.txt

test:
	./quicksort -size=$(SIZE) -input=quicksort_input_134217728 -gold=quicksort_gold_$(SIZE) -iterations=1

generate:
	./quicksort -size=$(SIZE) -input=quicksort_input_134217728 -gold=quicksort_gold_$(SIZE) -generate -iterations=1
	
quicksort_generate: clean
	$(NVCC) -o $(TARGET) cdpAdvancedQuicksort.cu cdpBitonicSort.cu  $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)

clean:
	rm -f *.o *~ $(TARGET)

