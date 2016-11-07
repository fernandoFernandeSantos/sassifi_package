#set parameters for fi
import os

benchmark = os.environ['BENCHMARK']
local = 'example'
times = 10

apps_p = {
    #'lava': ['example', 'lava', 3],
    #'hotspot':['example', 'hotspot',3],
    benchmark : [local, benchmark, times],
    #'mergesort': ['example', 'mergesort', 3],
    #'quicksort': ['example', 'quicksort', 3],
    #'nw': ['example', 'nw',3],
   #lulesh': ['example', 'lulesh', 3],
}

num_regs_p = {
    'lava': {"_Z15kernel_gpu_cuda7par_str7dim_strP7box_strP11FOUR_VECTORPdS4_":58},
    'hotspot': {'_Z14calculate_tempiPfS_S_iiiiffffff':38,},
    'mergesort': {'_Z30mergeElementaryIntervalsKernelILj1EEvPjS0_S0_S0_S0_S0_jj':16,'_Z21mergeSortSharedKernelILj1EEvPjS0_S0_S0_j':20},
    'mergesort_h': {'_Z30mergeElementaryIntervalsKernelILj1EEvPjS0_S0_S0_S0_S0_jj':16,'_Z21mergeSortSharedKernelILj1EEvPjS0_S0_S0_j':20,'_Z16sortVerifyKernelPjS_S_S_':10},
    'accl' : {'_Z16mergeSpansKernelPiS_iii':53,'_Z19relabelUnrollKernelPiiiiiii':10,},		   
    'quicksort' : {'_Z10qsort_warpPjS_jjP17qsortAtomicData_tP14qsortRingbuf_tjj':26,'_Z11bitonicsortPjS_jj':12,'_Z15big_bitonicsortPjS_S_jj':18},
    'nw':{'_Z20needle_cuda_shared_1PiS_iiii':26,'_Z20needle_cuda_shared_2PiS_iiii':26,},
    'lulesh': {'_Z42CalcKinematicsAndMonotonicQGradient_kerneliidPKiPKdS2_S2_S2_S2_S2_S2_S2_PdS3_S3_S3_S3_S3_S3_S3_S3_S3_S3_S3_S3_Pii': 128,
	       '_Z30CalcVolumeForceForElems_kernelILb1EEvPKdS1_S1_S1_diiPKiS1_S1_S1_S1_S1_S1_S1_S1_PdS4_S4_Pii':254,
	       '_Z45ApplyMaterialPropertiesAndUpdateVolume_kernelidddPdS_S_S_dddddPiS_S_S_S_dS_dS0_iPKiS2_i':87,},
    'lud':{'_Z13lud_perimeterPdii':44,'_Z12lud_diagonalPdii':44,},
    'hog_hardened_ecc_off':{ '_Z37classify_hists_kernel_many_blocks_extILi256ELi1EEviiiiPKfS1_ffPh':25, '_Z38normalize_hists_kernel_many_blocks_extILi64ELi1EEviiPff':30,},
          #'_Z36compute_hists_kernel_many_blocks_extILi1EEviN2cv3gpu7PtrStepIfEENS2_IhEEfPf':32,
          #'_Z33compute_gradients_8UC4_kernel_extILi256ELi1EEviiN2cv3gpu7PtrStepIhEEfNS2_IfEES3_':31,
          #           '_Z25resize_for_hog_kernel_extffN2cv3gpu9PtrStepSzI6uchar4EEi':11,
}

NUM_INJECTIONS_P = 3000

verbose_p = True

THRESHOLD_JOBS_P = 800 #400# test

#########################################################################
NUM_GPUS_P = 1


