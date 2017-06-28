include ../common_env.mk

TARGET = accl

OBJS=accl.o accl_main.o

OBJS_GEN=accl.o accl_generate.o

NVCC_FLAGS = $(GENCODE) $(LOG_FLAGS) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda -rdc=true -Xptxas -v -I$(CUDA_BASE_DIR)/include/ $(EXTRA_NVCC_FLAGS) -Xcompiler " -fopenmp"
LINK_FLAGS = -std=c++11  -lcudart -lcudadevrt $(EXTRA_LINK_FLAGS)

LINE=$(DEVICE_OBJS) $(LINK_OBJS) $(CPP_SOURCES) ../include/log_helper.c -I$(LOGHELPER_INC) -L/usr/local/cuda/lib64 -lcudart -lcuda -lcudadevrt -lpthread -fopenmp

all: $(TARGET) install


install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/

test:

$(TARGET): $(OBJS)
	$(CXX) $(COMMON) $^ -o $@  $(LDFLAGS) $(LDFLAGS) $(CFLAGS) -L$(CUDA_LIB_DIR) -lcudadevrt -lcudart -lcuda -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda $(LOG_FLAGS) $(LINK_FLAGS)
	

$(SOURCEDIR)%.o: %.cpp
	$(CXX) $(COMMON) -c $^  -o $@  $(LOG_FLAGS) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) \
		-lcudadevrt -lcudart -lcuda $(LDFLAGS) $(CFLAGS)  -L$(CUDA_LIB_DIR) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda $(LOG_FLAGS)\
		 $(LINK_FLAGS)
	
$(SOURCEDIR)%.o: %.cu 
	$(NVCC) $(ARCH) -c $< -o $@  $(LDFLAGS) $(CFLAGS) $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) \
	$(LINK_FLAGS) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda $(LOG_FLAGS) 
	

generate:
	./accl_generate 2 1 2Frames.pgm GOLD_2Frames

test: accl
	./accl 2 1 2Frames.pgm GOLD_2Frames 1 -verbose

golden: accl
	./accl 2 1 2Frames.pgm GOLD_2Frames 1 -verbose > golden_stdout.txt 2> golden_stderr.txt
	
clean:
	rm -f $(OBJS) $(TARGET)
