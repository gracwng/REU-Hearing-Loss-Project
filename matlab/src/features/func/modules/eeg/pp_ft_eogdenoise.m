%> @file  pp_ft_eogdenoise.m
%> @brief Denoise EEG data using <preproc_eogdenoise>

function dat = pp_ft_eogdenoise(dat,bids_events,bids_channels)

cfg             = [];
cfg.demean      = 1;
cfg.zthresh     = 4;
cfg.eogchan     = {'EOG','Fp1','Fpz','Fp2'};
cfg.pthresh     = 0.8;
cfg.artseg      = [];
[~,dat]         = preproc_eogdenoise(cfg,dat);