%> @file  pp_ft_highpass05_fs64_attention.m
%> @brief Highpass 64 Hz digitized EEG data at 0.5 Hz using a 212th order FIR filter

function dat = pp_ft_highpass05_fs64_attention(dat)

cfg             = [];
cfg.hpfilter    = 'yes';
cfg.hpfreq      = 0.5;
cfg.hpfilttype  = 'firws';
cfg.hpfiltdir   = 'onepass-zerophase';
cfg.hpfiltorder = 212;
cfg.hpfiltwintype = 'hamming';
dat             = ft_preprocessing(cfg,dat);