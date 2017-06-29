include ../common_env.mk

TARGET = lud

NVCC_FLAGS =  $(LOG_FLAGS) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda -rdc=true -Xptxas -v -I$(CUDA_BASE_DIR)/include/ $(EXTRA_NVCC_FLAGS) -Xcompiler " -fopenmp"
LINK_FLAGS = -std=c++11 $(GENCODE) -lcublas  -lcudart -lcudadevrt $(EXTRA_LINK_FLAGS)
#-lcublas_device

all: clean $(TARGET) install

$(TARGET):
	$(NVCC) -o lud lud.cu lud_kernel.cu $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)

install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/

golden:
	./$(TARGET) -matrix_size=$(SIZE) -reps=1 -input=lud_input_$(SIZE) -gold=lud_gold_$(SIZE) > golden_stdout.txt 2>golden_stderr.txt

test:
	./$(TARGET) -matrix_size=$(SIZE) -reps=1 -input=lud_input_$(SIZE) -gold=lud_gold_$(SIZE)

generate:
	./$(TARGET) -matrix_size=$(SIZE) -reps=1 -generate -generategold

clean:
	rm -f *.o *~ lud

