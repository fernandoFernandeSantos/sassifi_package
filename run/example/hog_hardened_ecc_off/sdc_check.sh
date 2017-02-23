#!/bin/bash
touch diff.log
diff  <(sed 's/:::Injecting.*::://g' stdout.txt) ${APP_DIR}/golden_stdout.txt > stdout_diff.log
diff stderr.txt ${APP_DIR}/golden_stderr.txt > stderr_diff.log
