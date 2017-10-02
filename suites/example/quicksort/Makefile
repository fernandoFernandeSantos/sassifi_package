include ../common_env.mk

TARGET = quicksort

NVCC_FLAGS =  $(LOG_FLAGS) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelper -rdc=true -Xptxas -v -I$(CUDA_BASE_DIR)/include/ $(EXTRA_NVCC_FLAGS) -Xcompiler " -fopenmp"
LINK_FLAGS = -std=c++11 $(GENCODE) -lcudart -lcudadevrt $(EXTRA_LINK_FLAGS)

all: clean $(TARGET) install

$(TARGET):
	$(NVCC) -o $(TARGET) cdpAdvancedQuicksort.cu cdpBitonicSort.cu  $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)

install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/

golden:
	./quicksort -size=1048576 -input=quicksort_input_134217728 -gold=quicksort_gold_1048576 -iterations=1 > golden_stdout.txt 2>golden_stderr.txt

test:
	./quicksort -size=1048576 -input=quicksort_input_134217728 -gold=quicksort_gold_1048576 -iterations=1

generate:
	./quicksort -size=1048576 -input=quicksort_input_134217728 -gold=quicksort_gold_1048576 -generate -iterations=1
	
quicksort_generate: clean
	$(NVCC) -o $(TARGET) cdpAdvancedQuicksort.cu cdpBitonicSort.cu  $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)

clean:
	rm -f *.o *~ $(TARGET)

