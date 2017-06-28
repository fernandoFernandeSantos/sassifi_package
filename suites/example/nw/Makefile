include ../common_env.mk

TARGET = nw

NVCC_FLAGS =  $(LOG_FLAGS) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda -rdc=true -Xptxas -v -I$(CUDA_BASE_DIR)/include/ $(EXTRA_NVCC_FLAGS) -Xcompiler " -fopenmp"
LINK_FLAGS = -std=c++11 $(GENCODE) -lcudart -lcudadevrt $(EXTRA_LINK_FLAGS)

all: clean $(TARGET) install

$(TARGET): 
	$(NVCC) -o nw needle.cu $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)

install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/

test:
		./nw 2048 10 input_2048 gold_2048 1

golden:
		./nw 2048 10 input_2048 gold_2048 1 > golden_stdout.txt 2>golden_stderr.txt

generate:
	$(NVCC)  $(DEBUG_FLAGS) needle_generate.cu -o $(TARGET)_generate -std=c++11 
	./nw_generate 2048 10 input_2048

clean:
	rm -f *.o *~ $(TARGET)

