export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

#BIN_DIR=~/SASSIFI/sassifi_package/suites/example/darknet
#APP_DIR=~/SASSIFI/sassifi_package/suites/example/darknet

# ./darknet yolo valid cfg/yolo.cfg yolo.weights
#${BIN_DIR}/darknet yolo valid ${APP_DIR}/cfg/yolo.cfg ${APP_DIR}/yolo.weights ${APP_DIR}/ > stdout.txt 2> stderr.txt 
#${BIN_DIR}/darknet -e yolo -m valid -c /home/carol/radiation-benchmarks/data/darknet/yolo.cfg -w /home/carol/radiation-benchmarks/data/darknet/yolo.weights -n 3 -d ${APP_DIR}gold/gold_voc2012.test -l /home/carol/radiation-benchmarks/data/VOC2012/voc.2012.FULL.txt -b /home/carol/radiation-benchmarks/src/cuda/darknet/ -x 0 > stdout.txt 2> stderr.txt

#${BIN_DIR}/darknet -e yolo -m valid -n 1  -x 0 -s 0 -a 0 -c ${APP_DIR}cfg/yolo.cfg \
#			  -w /home/carol/radiation-benchmarks/src/cuda/darknet/data/yolo.weights \
#			  -d ${APP_DIR}data/gold_FI.caltech.test \
#			  -l ${APP_DIR}data/FI.caltech.txt \
#			  -b ${APP_DIR} > stdout.txt 2> stderr.txt

${BIN_DIR}/darknet -a 0 -c /home/carol/radiation-benchmarks/data/darknet/yolo.cfg \
		   -b /home/carol/SASSIFI/sassifi_package/suites/example/darknet -e yolo  \
		   -d /home/carol/radiation-benchmarks/data/darknet/gold.caltech.critical.abft.1K.test \
		   -m valid -l /home/carol/radiation-benchmarks/data/networks_img_list/caltech.pedestrians.critical.1K.txt \
		   -n 1 -s 1 -w /home/carol/radiation-benchmarks/data/darknet/yolo.weights  -x 0 > stdout.txt 2> stderr.txt

