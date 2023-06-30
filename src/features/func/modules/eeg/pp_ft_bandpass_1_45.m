%> @file  pp_ft_bandpass_1_45.m
%> @brief Bandpass EEG feature between 1 Hz and 45 Hz using a 6th order
%> Butterworth filter. This was used during peer review process. 

function dat = pp_ft_bandpass_1_45(dat)

cfg             = [];
cfg.bpfilter    = 'yes';
cfg.bpfreq      = [1 45];
cfg.bpfilttype   = 'but';
cfg.bpfiltord   = 6;
cfg.bpfiltdir = 'twopass';
dat             = ft_preprocessing(cfg,dat);