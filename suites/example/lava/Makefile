include ../common_env.mk

TARGET = lava

NVCC_FLAGS =  $(LOG_FLAGS) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda -rdc=true -Xptxas -v -I$(CUDA_BASE_DIR)/include/ $(EXTRA_NVCC_FLAGS) -Xcompiler " -fopenmp"
LINK_FLAGS = -std=c++11 $(GENCODE) -I$(CUDA_LIB_DIR) -lcudart -lcudadevrt $(EXTRA_LINK_FLAGS)

all: clean $(TARGET) install

$(TARGET):
	$(NVCC) -o lava lava.cu $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)

install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/

test:
	./$(TARGET) -boxes=10 -input_distances=input_distances_10 -input_charges=input_charges_10 -output_gold=GOLD -iterations=1 -streams=1

golden:
	./$(TARGET) -boxes=10 -input_distances=input_distances_10 -input_charges=input_charges_10 -output_gold=GOLD -iterations=1 -streams=1 > golden_stdout.txt 2> golden_stderr.txt

generate: ./lava
	./$(TARGET) -boxes=10 -generate -output_gold=GOLD -iterations=1 -streams=1
	
lava_generate:
	$(NVCC) -o $(TARGET) lava.cu $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)

clean:
	rm -f *.o *~ lava
