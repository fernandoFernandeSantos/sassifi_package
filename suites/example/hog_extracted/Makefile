include ../common_env.mk

TARGET = hog_extracted
HOG_EXT_DIR=.
GOLD=gold_gen

ALL_CV_FLAGS=-L/usr/local/lib -lopencv_core -lopencv_imgproc -lopencv_highgui  -lopencv_objdetect
ALL_GOLD_GEN=-I/usr/local/include/opencv -I/usr/local/include  -L/usr/local/lib -L/usr/local/cuda-7.0/lib64 -lopencv_calib3d -lopencv_contrib -lopencv_core -lopencv_features2d -lopencv_flann -lopencv_gpu -lopencv_highgui -lopencv_imgproc -lopencv_legacy -lopencv_ml -lopencv_nonfree -lopencv_objdetect -lopencv_ocl -lopencv_photo -lopencv_stitching -lopencv_superres -lopencv_ts -lopencv_video -lopencv_videostab -lcufft -lcublas -lnpps -lnppi -lnppc -lcudart -lrt -lpthread -lm -ldl  

DATASET=/home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.critical.1K.txt

NVCC_FLAGS =  $(LOG_FLAGS) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda -rdc=true -Xptxas -v -I$(CUDA_BASE_DIR)/include/ $(EXTRA_NVCC_FLAGS) -Xcompiler " -fopenmp"
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


hog_extracted_generate: $(HOG_EXT_DIR)/GoldGenerator.cpp
	$(CXX) $(HOG_EXT_DIR)/GoldGenerator.cpp -Wall  -o3 -lopencv_core -I$(LOGHELPER_INC) $(ALL_GOLD_GEN) -o $(HOG_EXT_DIR)/$(GOLD) -L/usr/local/lib -L/usr/local/cuda-7.0/lib64 -I/usr/local/cuda-7.0/include


golden:
	./$(TARGET) $(DATASET) --iterations 1 > golden_stdout.txt 2>golden_stderr.txt

test:
	./$(TARGET) $(DATASET) --iterations 1


generate:
	./$(GOLD) $(DATASET) --hit_threshold 0.9 --gr_threshold 1 --nlevels 100


clean:
	rm -f *.o *~ $(TARGET) $(GOLD)

