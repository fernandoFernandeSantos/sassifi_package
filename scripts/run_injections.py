################################################################################### 
# Copyright (c) 2015, NVIDIA CORPORATION. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#  * Neither the name of NVIDIA CORPORATION nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
# OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
###################################################################################

import os, sys, re, string, operator, math, datetime, subprocess, time, multiprocessing, pkgutil
import common_params as cp
import specific_params as sp
import subprocess
###############################################################################
# Basic functions and parameters
###############################################################################
before = -1

def print_usage():
    print "Usage: \n run_injections.py rf/inst standalone/multigpu/cluster <clean>"
    print "Example1: \"run_injections.py rf standalone\" to run jobs on the current system"
    print "Example1: \"run_injections.py inst multigpu\" to run jobs on the current system using multiple gpus"
    print "Example2: \"run_injections.py inst cluster clean\" to launch jobs on cluster and clean all previous logs/results"

############################################################################
# Print progress every 10 minutes for jobs submitted to the cluster
############################################################################
def print_heart_beat(nj, where_to_run):
    if where_to_run != "cluster":
        return
    global before
    if before == -1:
        before = datetime.datetime.now()
    if (datetime.datetime.now()-before).seconds >= 10*60:
        print "Jobs so far: %d" %nj
        before = datetime.datetime.now()

def get_log_name(app, igid, bfm):
    return sp.app_log_dir[app] + "results-igid" + str(igid) + ".bfm" + str(bfm) + "." + str(sp.NUM_INJECTIONS) + ".txt"

############################################################################
# Clear log conent. Default is to append, but if the user requests to clear
# old logs, use this function.
############################################################################
def clear_results_file(app):
    for bfm in sp.rf_bfm_list: 
        open(get_log_name(app, "rf", bfm)).close()
    for igid in sp.igid_bfm_map:
        for bfm in sp.igid_bfm_map[igid]:
            open(get_log_name(app, igid, bfm)).close()

############################################################################
# count how many jobs are done
############################################################################
def count_done(fname):
    return sum(1 for line in open(fname)) # count line in fname 


############################################################################
# check queue and launch multiple jobs on a cluster 
# This feature is not implemented.
############################################################################
def check_and_submit_cluster(cmd):
        print "This feature is not implement. Please write code here to submit jobs to your cluster.\n"
        sys.exit(-1)

############################################################################
# check queue and launch multiple jobs on the multigpu system 
############################################################################
jobs_list = []
pool = multiprocessing.Pool(sp.NUM_GPUS) # create a pool

def check_and_submit_multigpu(cmd):
    if len(jobs_list) == sp.NUM_GPUS:
        pool.map(os.system, jobs_list) # launch jobs in parallel
        del jobs_list[:] # clear the list
    else:
        jobs_list.append("CUDA_VISIBLE_DEVICES=" + str(len(jobs_list)) + " " + cmd)
        # print "appending.. " 


###############################################################################
# Run Multiple injection experiments
###############################################################################
def run_multiple_injections_igid(app, is_rf, igid, where_to_run):
    bfm_list = sp.rf_bfm_list if is_rf else sp.igid_bfm_map[igid]
 
    for bfm in bfm_list:
        #print "App: %s, IGID: %s, EM: %s" %(app, cp.IGID_STR[igid], cp.EM_STR[bfm])
        total_jobs = 0
        inj_list_filenmae = sp.app_log_dir[app] + "/injection-list/igid" + str(igid) + ".bfm" + str(bfm) + "." + str(sp.NUM_INJECTIONS) + ".txt"
        inf = open(inj_list_filenmae, "r")
        for line in inf: # for each injection site 
            total_jobs += 1
            if total_jobs > sp.THRESHOLD_JOBS: 
                break; # no need to run more jobs

            #_Z24bpnn_adjust_weights_cudaPfiS_iS_S_ 0 1297034 0.877316323856 0.214340876321
            if len(line.split()) >= 5: 
                [kname, kcount, iid, opid, bid] = line.split() # obtains params for this injection
                if cp.verbose: print "\n%d: app=%s, Kernel=%s, kcount=%s, igid=%s, bfm=%s, instID=%s, opID=%s, bitLocation=%s" %(total_jobs, app, kname, str(kcount), str(igid), bfm, iid, opid, bid)
                cmd = "%s %s/scripts/run_one_injection.py %s %s %s %s %s %s %s %s" %(cp.PYTHON_P, sp.SASSIFI_HOME, str(igid), str(bfm), app, kname, kcount, iid, opid, bid)
                if where_to_run == "cluster":
                    check_and_submit_cluster(cmd)
                elif where_to_run == "multigpu":
                    check_and_submit_multigpu(cmd)
                else:
                    os.system(cmd)
                if cp.verbose: print "done injection run "

                check_sdc_fernando(app, kname, kcount, igid, bfm, iid, opid, bid, ('rf' if is_rf else 'inst'))
            else:
                print "Line doesn't have enough params:%s" %line
            print_heart_beat(total_jobs, where_to_run)

#generic sdc verification
def check_sdc_fernando(app, kname, kcount, igid, bfm, iid, opid, bid, inj_type):
	fault_model = open(sp.SASSIFI_HOME + "logs_sdcs_"+str(app) + "-" + str(inj_type) + ".csv", "a")
    #########################################################
	proc = subprocess.Popen("ls -Art /var/radiation-benchmarks/log/ | tail -n 1", stdout=subprocess.PIPE, shell=True)
	(out, err) = proc.communicate()             
	has_sdc = 0
	has_end = 1
        sdc_caught = 2
	string_file = open(("/var/radiation-benchmarks/log/" + str(out).rstrip())).read()
	if "SDC" in string_file:
		has_sdc = 1
	if "END" not in string_file:
		has_end = 0
	if "DETECTED" in string_file:
		sdc_caught = 1
	if "MISSED" in string_file:
		sdc_caught = 0
    #########################################################
    #Kernel=%s, kcount=%s, igid=%s, bfm=%s, instID=%s, opID=%s, bitLocation=%s
	string_result = str([out.rstrip() , has_sdc, kname, kcount, igid, bfm, iid, opid, bid, has_end, sdc_caught]).translate(None, '[]\'')
	fault_model.write(string_result + "\n")
	fault_model.close()
 
###############################################################################
# wrapper function to call either RF injections or instruction level injections
###############################################################################
def run_multiple_injections(app, is_rf, where_to_run):
    if is_rf:
        run_multiple_injections_igid(app, is_rf, "rf", where_to_run)
    else:
        for igid in sp.igid_bfm_map:
            run_multiple_injections_igid(app, is_rf, igid, where_to_run)

###############################################################################
# Starting point of the execution
###############################################################################
def main(): 
    if len(sys.argv) >= 3: 
        where_to_run = sys.argv[2]
    
        if where_to_run != "standalone":
            if pkgutil.find_loader('lockfile') is None:
                print "lockfile module not found. This python module is needed to run injection experiments in parallel." 
                sys.exit(-1)
    
        sorted_apps = [app for app, value in sorted(sp.apps.items(), key=lambda e: e[1][2])] # sort apps according to expected runtimes
        for app in sorted_apps: 
            print app
            if not os.path.isdir(sp.app_log_dir[app]): os.system("mkdir -p " + sp.app_log_dir[app]) # create directory to store summary
            if len(sys.argv) == 4: 
                if sys.argv[3] == "clean":
                    clear_results_file(app) # clean log files only if asked for
    
            run_multiple_injections(app, (sys.argv[1] == "rf"), where_to_run)
    
    else:
        print_usage()

if __name__ == "__main__":
    main()
