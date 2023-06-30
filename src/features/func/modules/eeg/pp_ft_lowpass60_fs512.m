%> @file  pp_ft_lowpass60_fs512.m
%> @brief Lowpass 512 Hz digitized EEG data at 60 Hz using a 114th order FIR filter

function dat = pp_ft_lowpass60_fs512(dat)

cfg = [];
cfg.lpfilter    = 'yes';
cfg.lpfreq      = 60;
cfg.lpfilttype  = 'firws';
cfg.lpfiltdir   = 'onepass-zerophase';
cfg.lpfiltorder = 114;
cfg.lpfiltwintype = 'hamming';
dat = ft_preprocessing(cfg,dat);