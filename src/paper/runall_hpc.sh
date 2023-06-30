#!/bin/bash
#SBATCH --partition=HPC
/mnt/depot64/matlab/R2018a/bin/matlab -nodesktop -nosplash -r \
"addpath('/home/sorenaf/documents/utils/ds-nhhi'); \
bidsdir   = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; \
sdir      = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/'; \
runall($SLURM_ARRAY_TASK_ID,bidsdir,sdir); \
exit" 
