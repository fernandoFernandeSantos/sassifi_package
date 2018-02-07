# set parameters for fi
# it is an easier way to set all parameters for SASSIFI, it is the same as setting it on specific_param.py

import os

benchmark = os.environ['BENCHMARK']
local = 'example'
times = 20

#########################################################################
# List of apps
# app_name: [suite name, binary name, expected runtime in secs on the target PC]
#########################################################################
apps_p = {
    benchmark: [local, benchmark, times],
}

# Specify the number of injection sites to create before starting the injection
# campaign. This is essentially the maximum number of injections one can run
# per instruction group (IGID) and bit-flip model (BFM).
NUM_INJECTIONS_P = 1000

# print information
verbose_p = True

# Specify how many injections you want to perform per IGID and BFM combination.
# Only the first THRESHOLD_JOBS will be selected from the generated NUM_INJECTIONS.
THRESHOLD_JOBS_P = int(os.environ['THRESHOLD_JOBS_ENV_VAR'])

#########################################################################
# Number of gpus to use for error injection runs
#########################################################################
NUM_GPUS_P = 1

#########################################################################
# upper and lower bounds of bit flip index
# for example if you want flip only the less significant 16 bits
# set upper_bound = 0.5 and lower_bound = 0.0
#########################################################################
upper_bound = 1.0
lower_bound = 0.0
