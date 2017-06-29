include ../common_env.mk


TARGET = mergesort

NVCC_FLAGS =  $(logs) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda -rdc=true -Xptxas -v -I$(CUDA_BASE_DIR)/include/ $(EXTRA_NVCC_FLAGS) \
-Xcompiler " -fopenmp" -Xcompiler "-O3"
LINK_FLAGS = -std=c++11 $(GENCODE) -lcudart -lcudadevrt $(EXTRA_LINK_FLAGS)

all: clean $(TARGET) install

$(TARGET):
	$(NVCC) -o mergesort bitonic.cu main.cpp mergeSort.cu mergeSort_host.cpp mergeSort_validate.cpp  $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)

install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/


test:
	./$(TARGET) -size=1048576 -input=mergesort_input_134217728 -gold=mergesort_gold_1048576 -iterations=1

golden:
	./$(TARGET) -size=1048576 -input=mergesort_input_134217728 -gold=mergesort_gold_1048576 -iterations=1 > golden_stdout.txt 2>golden_stderr.txt

generate:
	./$(TARGET) -size=1048576 -input=mergesort_input_134217728 -gold=mergesort_gold_1048576 -iterations=1


clean:
	rm -f *.o *~ $(TARGET)

