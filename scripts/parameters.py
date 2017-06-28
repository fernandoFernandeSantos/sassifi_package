#set parameters for fi
#it is an easier way to set all parameters for SASSIFI, it is the same as setting it on specific_param.py

import os

benchmark = os.environ['BENCHMARK']
local = 'example'
times = 10

#########################################################################
# List of apps 
# app_name: [suite name, binary name, expected runtime in secs on the target PC]
#########################################################################
apps_p = {
    benchmark : [local, benchmark, times],
}

# Specify the number of injection sites to create before starting the injection
# campaign. This is essentially the maximum number of injections one can run
# per instruction group (IGID) and bit-flip model (BFM).
NUM_INJECTIONS_P = 1000

#print information
verbose_p = True

# Specify how many injections you want to perform per IGID and BFM combination. 
# Only the first THRESHOLD_JOBS will be selected from the generated NUM_INJECTIONS.
THRESHOLD_JOBS_P = 1


#########################################################################
# Number of gpus to use for error injection runs
#########################################################################
NUM_GPUS_P = 1


#########################################################################
# upper and lower bounds of bit flip index
# for example if you want flip only the less significant 16 bits
# set upper_bound = 0.5 and lower_bound = 0.0
#########################################################################
upper_bound = 0.5
lower_bound = 0.0


#~ num_regs_p = {
    #~ 'lava': {"_Z15kernel_gpu_cuda7par_str7dim_strP7box_strP11FOUR_VECTORPdS4_":58},
    #~ 'hotspot': {'_Z14calculate_tempiPfS_S_iiiiffffff':38,},
    #~ 'mergesort': {'_Z30mergeElementaryIntervalsKernelILj1EEvPjS0_S0_S0_S0_S0_jj':16,'_Z21mergeSortSharedKernelILj1EEvPjS0_S0_S0_j':20},
    #~ 'mergesort_h': {'_Z30mergeElementaryIntervalsKernelILj1EEvPjS0_S0_S0_S0_S0_jj':16,'_Z21mergeSortSharedKernelILj1EEvPjS0_S0_S0_j':20,'_Z16sortVerifyKernelPjS_S_S_':10},
    #~ 'accl' : {'_Z16mergeSpansKernelPiS_iii':53,'_Z19relabelUnrollKernelPiiiiiii':10,},		   
    #~ 'quicksort' : {'_Z10qsort_warpPjS_jjP17qsortAtomicData_tP14qsortRingbuf_tjj':26,'_Z11bitonicsortPjS_jj':12,'_Z15big_bitonicsortPjS_S_jj':18},
    #~ 'nw':{'_Z20needle_cuda_shared_1PiS_iiii':26,'_Z20needle_cuda_shared_2PiS_iiii':26,},
    #~ 'lulesh': {'_Z42CalcKinematicsAndMonotonicQGradient_kerneliidPKiPKdS2_S2_S2_S2_S2_S2_S2_PdS3_S3_S3_S3_S3_S3_S3_S3_S3_S3_S3_S3_Pii': 128,
	       #~ '_Z30CalcVolumeForceForElems_kernelILb1EEvPKdS1_S1_S1_diiPKiS1_S1_S1_S1_S1_S1_S1_S1_PdS4_S4_Pii':254,
	       #~ '_Z45ApplyMaterialPropertiesAndUpdateVolume_kernelidddPdS_S_S_dddddPiS_S_S_S_dS_dS0_iPKiS2_i':87,},
    #~ 'lud':{'_Z13lud_perimeterPdii':44,'_Z12lud_diagonalPdii':44,},
    #~ 
    #~ 'hog_hardened_ecc_off':{'_Z36compute_hists_kernel_many_blocks_extILi1EEviN2cv3gpu7PtrStepIfEENS2_IhEEfPf':32,
							#~ '_Z37classify_hists_kernel_many_blocks_extILi256ELi1EEviiiiPKfS1_ffPh':25, 
							#~ '_Z38normalize_hists_kernel_many_blocks_extILi64ELi1EEviiPff':30, 
							#~ '_Z33compute_gradients_8UC4_kernel_extILi256ELi1EEviiN2cv3gpu7PtrStepIhEEfNS2_IfEES3_':31,
							#~ '_Z25resize_for_hog_kernel_extffN2cv3gpu9PtrStepSzI6uchar4EEi':11,
                     #~ },
    #~ 'hog_extracted':{'_Z36compute_hists_kernel_many_blocks_extILi1EEviN2cv3gpu7PtrStepIfEENS2_IhEEfPf':32,
							#~ '_Z37classify_hists_kernel_many_blocks_extILi256ELi1EEviiiiPKfS1_ffPh':19, 
							#~ '_Z38normalize_hists_kernel_many_blocks_extILi64ELi1EEviiPff':23, 
							#~ '_Z33compute_gradients_8UC4_kernel_extILi256ELi1EEviiN2cv3gpu7PtrStepIhEEfNS2_IfEES3_':31,
							#~ '_Z25resize_for_hog_kernel_extffN2cv3gpu9PtrStepSzI6uchar4EEi':11,
		#~ },
	#~ 'hog_hardned_ecc_on':{'_Z36compute_hists_kernel_many_blocks_extILi1EEviN2cv3gpu7PtrStepIfEENS2_IhEEfPf':32,
							#~ '_Z37classify_hists_kernel_many_blocks_extILi256ELi1EEviiiiPKfS1_ffPh':25, 
							#~ '_Z38normalize_hists_kernel_many_blocks_extILi64ELi1EEviiPff':30, 
							#~ '_Z33compute_gradients_8UC4_kernel_extILi256ELi1EEviiN2cv3gpu7PtrStepIhEEfNS2_IfEES3_':31,
							#~ '_Z25resize_for_hog_kernel_extffN2cv3gpu9PtrStepSzI6uchar4EEi':11,
							#~ },
#~ 
   #~ 'darknet':{'_Z16constrain_kernelifPfi': 5, '_Z15variance_kernelPfS_iiiS_': 26, 
	 #~ '_Z21weighted_delta_kerneliPfS_S_S_S_S_S_': 16, '_Z17im2col_gpu_kerneliPKfiiiiiiiPf': 31,
	 #~ '_Z28forward_maxpool_layer_kerneliiiiiiiPfS_Pi': 21, '_Z21variance_delta_kernelPfS_S_S_iiiS_': 23,
	 #~ '_Z28forward_softmax_layer_kerneliiPffS_': 26, '_Z29backward_avgpool_layer_kerneliiiiPfS_': 22,
	 #~ '_Z21backward_scale_kernelPfS_iiiS_': 19, '_Z20backward_bias_kernelPfS_iii': 14, '_Z11scal_kernelifPfi': 5,
	 #~ '_Z22fast_mean_delta_kernelPfS_iiiS_': 18, '_Z11mask_kerneliPffS_': 6, '_Z11axpy_kernelifPfiiS_ii': 8, 
	 #~ '_Z22normalize_delta_kerneliPfS_S_S_S_iiiS_': 23, '_Z15binarize_kernelPfiS_': 7, '_Z15add_bias_kernelPfS_ii': 6,
	 #~ '_Z21activate_array_kernelPfi10ACTIVATION': 18, '_Z17mean_delta_kernelPfS_iiiS_': 18,
	 #~ '_Z19levels_image_kernelPfS_iiiifffff': 31, '_Z23binarize_weights_kernelPfiiS_': 20, '_Z9l2_kerneliPfS_S_S_': 12,
	 #~ '_Z10mul_kerneliPfiS_i': 8, '_Z20mult_add_into_kerneliPfS_S_': 8, '_Z12const_kernelifPfi': 5,
	 #~ '_Z12reorg_kerneliPfiiiiiiS_': 27, '_Z19weighted_sum_kerneliPfS_S_S_': 10, '_Z16fast_mean_kernelPfiiiS_': 18,
	 #~ '_Z29backward_maxpool_layer_kerneliiiiiiiPfS_Pi': 30, '_Z16normalize_kerneliPfS_S_iii': 18, 
	 #~ '_Z20fast_variance_kernelPfS_iiiS_': 31, '_Z11supp_kernelifPfi': 6, '_Z21binarize_input_kernelPfiiS_': 18,
	 #~ '_Z11mean_kernelPfiiiS_': 18, '_Z15shortcut_kerneliiiiiiiiiiPfiiiS_': 19, 
	 #~ '_Z25forward_crop_layer_kernelPfS_iiiiiiiifS_': 30, '_Z28forward_avgpool_layer_kerneliiiiPfS_': 18,
	 #~ '_Z26fast_variance_delta_kernelPfS_S_S_iiiS_': 34, '_Z21gradient_array_kernelPfi10ACTIVATIONS_': 6,
	 #~ '_Z17accumulate_kernelPfiiS_': 14, '_Z16smooth_l1_kerneliPfS_S_S_': 12, '_Z28yoloswag420blazeit360noscopePfiS_ff': 6,
	 #~ '_Z11copy_kerneliPfiiS_ii': 8, '_Z10pow_kernelifPfiS_i': 19, '_Z11fill_kernelifPfi': 5,
	 #~ '_Z17scale_bias_kernelPfS_ii': 6, '_Z17col2im_gpu_kerneliPKfiiiiiiiPf': 35},
#~ }
