include ../common_env.mk

TARGET = lulesh

NVCC_FLAGS =  $(LOG_FLAGS) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda -rdc=true -Xptxas -v -I$(CUDA_BASE_DIR)/include/ $(EXTRA_NVCC_FLAGS) -Xcompiler " -fopenmp"
LINK_FLAGS = -std=c++11 $(GENCODE) -lcudart -lcudadevrt $(EXTRA_LINK_FLAGS)

all:clean $(TARGET) install

$(TARGET): allocator.o lulesh.o
	#lulesh-comms-gpu.o lulesh-comms.o lulesh-comms.o lulesh-comms-gpu.o
	$(NVCC) $(LOG_FLAGS) allocator.o lulesh.o  -o $(TARGET)  $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)

allocator.o: allocator.cu vector.h
	$(NVCC) $(FLAGS) allocator.cu -I ./ -c -o allocator.o  $(LINK_FLAGS)

lulesh.o: lulesh.cu util.h vector.h allocator.h
	$(NVCC) $(LINKFLAGS) $(LOG_FLAGS) $(FLAGS) lulesh.cu -I ./  $(INC_SILO) -c -o lulesh.o   $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)

install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/

generate:
	 ./$(TARGET) -s 50 -i 1 -g 1 gold_50

golden:
	 ./$(TARGET) -s 50 -i 1 -g 0 gold_50 > golden_stdout.txt 2>golden_stderr.txt

test:
	 ./$(TARGET) -s 50 -i 1 -g 0 gold_50


lulesh_generate: clean allocator.o lulesh.o
	#lulesh-comms-gpu.o lulesh-comms.o lulesh-comms.o lulesh-comms-gpu.o
	$(NVCC) $(LOG_FLAGS) allocator.o lulesh.o  -o $(TARGET)  $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)

clean:
	rm -f *.o *~ $(TARGET)

