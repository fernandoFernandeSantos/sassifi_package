#!/bin/bash
touch diff.log
diff  <(sed 's/:::Injecting.*::://g' stdout.txt) ${APP_DIR}/golden_stdout.txt > stdout_diff.log
diff stderr.txt ${APP_DIR}/golden_stderr.txt > stderr_diff.log
LOG_FILE=`sudo ls -Art /var/radiation-benchmarks/log/ | tail -n 1`
HAS_SDC=0
if grep -q SDC /var/radiation-benchmarks/log/$LOG_FILE; 
then 
	HAS_SDC=1
else
	HAS_SDC=0
fi

IFS='/' read -ra ADDR <<< "${APP_DIR}"
LAST_PART=${ADDR[${#ADDR[@]} - 1 ]}

FAULT_MODEL=`cat /home/carol/SASSIFI/sassifi_package/fault_model.txt`
echo $LOG_FILE","$HAS_SDC","$FAULT_MODEL >> /home/carol/SASSIFI/sassifi_package/logs_sdcs_${LAST_PART}.csv
