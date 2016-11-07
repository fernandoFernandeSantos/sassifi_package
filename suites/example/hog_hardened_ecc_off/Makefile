TARGET = hog_hardened_ecc_off
SUITE_NAME = example

OPTION = none
CXX=g++

GENCODE = -gencode arch=compute_35,code=sm_35
INST_LIB_DIR = /home/carol/SASSIFI/SASSI/instlibs/lib/
REGRESSION_HOME = /home/carol/SASSIFI/sassifi_package/

# SASSI/CUDA
CUDA_BASE_DIR = /usr/local/sassi7/
CUDA_LIB_DIR = $(CUDA_BASE_DIR)/lib64
CUDA_BIN_DIR = $(CUDA_BASE_DIR)/bin
CUPTI_LIB_DIR = $(CUDA_BASE_DIR)/extras/CUPTI/lib64
CUPTI = -L$(CUPTI_LIB_DIR) -lcupti 
NVCC = $(CUDA_BIN_DIR)/nvcc

# The C/CPP compiler you want to use, and associated flags.
CC = gcc
CXX = g++
CFLAGS = -O3
CXXFLAGS = -O3
export CCDIR = /usr/bin/
export PATH := $(CCDIR)/bin/:$(PATH)
export LD_LIBRARY_PATH := $(CCDIR)/lib64:$(LD_LIBRARY_PATH):$(CUDA_LIB_DIR):$(CUPTI_LIB_DIR)

AFTER_REG = -Xptxas --sassi-inst-after="reg-writes" 
AFTER_MEM = -Xptxas --sassi-inst-after="memory" 
AFTER_REG_MEM = -Xptxas --sassi-inst-after="reg-writes\,memory" 
BEFORE_ALL = -Xptxas --sassi-inst-before="all"
BEFORE_COND_BRANCHES = -Xptxas --sassi-inst-before="cond-branches"
BEFORE_MEM = -Xptxas --sassi-inst-before="memory"
BEFORE_REGS = -Xptxas --sassi-inst-before="reg-writes,reg-reads"

AFTER_REG_INFO = -Xptxas --sassi-after-args="reg-info"
AFTER_MEM_INFO = -Xptxas --sassi-after-args="mem-info"
AFTER_REG_MEM_INFO = -Xptxas --sassi-after-args="reg-info\,mem-info"
BEFORE_COND_BRANCH_INFO = -Xptxas --sassi-before-args="cond-branch-info"
BEFORE_MEM_INFO = -Xptxas --sassi-before-args="mem-info"
BEFORE_REG_INFO = -Xptxas --sassi-before-args="reg-info"
BEFORE_REG_MEM_INFO = -Xptxas --sassi-before-args="reg-info\,mem-info"

BRANCH_AROUND = -Xptxas --sassi-iff-true-predicate-handler-call

ifeq (${OPTION},profiler)
EXTRA_NVCC_FLAGS = $(BEFORE_ALL) $(BEFORE_REG_MEM_INFO)
EXTRA_LINK_FLAGS = -L$(INST_LIB_DIR) -lprofiler $(CUPTI)
endif

ifeq (${OPTION},inst_injector)
EXTRA_NVCC_FLAGS = $(AFTER_REG_MEM) $(AFTER_REG_MEM_INFO) $(BRANCH_AROUND) 
EXTRA_LINK_FLAGS = -L$(INST_LIB_DIR) -linstinjector $(CUPTI)
endif
 
ifeq (${OPTION},rf_injector)
EXTRA_NVCC_FLAGS = $(BEFORE_ALL) $(BEFORE_REG_MEM_INFO) 
EXTRA_LINK_FLAGS = -L$(INST_LIB_DIR) -lrfinjector $(CUPTI)
endif

LOGHELPER_INC=../include/
LOGHELPER_LIB=../include/


#NVIDIA_INC=/usr/local/cuda-7.0/include/
#NVIDIA_LIB=/usr/local/cuda-7.0/lib64/

PURE_NVCC=/usr/local/cuda-7.0/bin/nvcc
LOGS=1
ifeq ($(LOGS), 1)
OPTS = -DLOGS
LOG_FLAGS = -I$(LOGHELPER_LIB) -L$(LOGHELPER_LIB) -lLogHelperCuda -DLOGS
endif

debug = -g -G
ALL_CV_FLAGS=-L/usr/local/lib -lopencv_core -lopencv_imgproc -lopencv_highgui  -lopencv_objdetect 

ALL_GOLD_GEN=-L/usr/local/lib -lopencv_core -lopencv_imgproc -lopencv_highgui  -lopencv_objdetect  -lopencv_gpu -lopencv_calib3d -lopencv_video -lopencv_legacy -lopencv_stitching -lopencv_superres \
			-lopencv_photo  -lopencv_ml -lopencv_ml \
			-lopencv_contrib -lopencv_features2d -lopencv_flann \
			-lopencv_nonfree 

#NVCC_FLAGS = -O3 -g -rdc=true -Xptxas -v
#LINK_FLAGS = -std=c++11 -g -lcudart -lcudadevrt -lm 
NVCC_FLAGS =  $(logs) -I$(LOGHELPER_INC) -L$(LOGHELPER_LIB) -lLogHelperCuda -rdc=true -Xptxas -v -I$(CUDA_BASE_DIR)/include/ $(EXTRA_NVCC_FLAGS) -Xcompiler " -fopenmp"
LINK_FLAGS = -std=c++11 $(GENCODE) -lcudart -lcudadevrt $(EXTRA_LINK_FLAGS)

all: clean $(TARGET) install

$(TARGET): HOG.cpp
	$(NVCC) opencv_src/hog.cu -c  $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)
	$(NVCC) opencv_src/HogDescriptor.cpp -c $(ALL_CV_FLAGS)
	$(NVCC) HOG.cpp -c $(ALL_CV_FLAGS) $(LOG_FLAGS)
	$(NVCC) -o $(TARGET) hog.o HogDescriptor.o HOG.o $(ALL_CV_FLAGS) $(LOG_FLAGS) -L/usr/local/cuda-7.0/lib64 -lcuda -lcudart -lcublas -lcurand $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)


#$(NVCC) -o hotspot hotspot.cu $(NVCC_FLAGS) -L$(CUDA_LIB_DIR) $(LINK_FLAGS)

install:
	mkdir -p $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/
	cp $(TARGET) $(REGRESSION_HOME)/bin/$(OPTION)/$(SUITE_NAME)/


gold_generator: GoldGenerator.cpp
	$(PURE_NVCC) GoldGenerator.cpp -o generator $(ALL_GOLD_GEN)

test:
	./$(TARGET) 1x_pedestrians.jpg --dst_data GOLD_1x.data --iterations 1

generate:
	./generator 1x_pedestrians.jpg --dst_data GOLD_1x.data --hit_threshold 0.9 --gr_threshold 1 --nlevels 100
	
golden:
	./$(TARGET) 1x_pedestrians.jpg --dst_data GOLD_1x.data --iterations 1  > golden_stdout.txt 2>golden_stderr.txt

clean:
	rm -rf $(TARGET) generator *~ *.o

