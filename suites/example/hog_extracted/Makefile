include ../common_env.mk

TARGET = hog_extracted
HOG_EXT_DIR=.

ALL_CV_FLAGS=-L/usr/local/lib -lopencv_core -lopencv_imgproc -lopencv_highgui  -lopencv_objdetect

NVCC_FLAGS =  $(logs) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda -rdc=true -Xptxas -v -I$(CUDA_BASE_DIR)/include/ $(EXTRA_NVCC_FLAGS) -Xcompiler " -fopenmp"
LINK_FLAGS = -std=c++11 $(GENCODE) -lcudart -lcudadevrt $(EXTRA_LINK_FLAGS) 

all: clean $(TARGET) install

#$(NVCC) -o hotspot hotspot.cu $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)

install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/


##hog extracted
$(TARGET):
	$(NVCC) $(HOG_EXT_DIR)/opencv_src/hog.cu -c -o $(HOG_EXT_DIR)/hog.o $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)
	$(NVCC) $(HOG_EXT_DIR)/opencv_src/HogDescriptor.cpp -c $(ALL_CV_FLAGS) -o $(HOG_EXT_DIR)/HogDescriptor.o $(LOG_FLAGS) $(CFLAGS) $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)
	$(NVCC) $(HOG_EXT_DIR)/HOG.cpp -c $(ALL_CV_FLAGS) -o $(HOG_EXT_DIR)/HOG.o $(LOG_FLAGS) $(CFLAGS) $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)
	$(NVCC) -o $(HOG_EXT_DIR)/$(TARGET) $(HOG_EXT_DIR)/hog.o $(LOGHELPER_INC)log_helper.o $(HOG_EXT_DIR)/HOG.o $(HOG_EXT_DIR)/HogDescriptor.o \
							$(ALL_CV_FLAGS) $(CFLAGS) $(LOG_FLAGS) $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)



golden:
	./$(TARGET) /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.critical.1K.txt --iterations 1 > golden_stdout.txt 2>golden_stderr.txt

test:
	./$(TARGET) /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.critical.1K.txt --iterations 1



clean:
	rm -f *.o *~ $(TARGET)

