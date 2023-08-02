%> @file  pp_ft_highpass1_fs64_attention.m
%> @brief Highpass 64 Hz digitized EEG data at 1 Hz using a 106th order FIR filter

function dat = pp_ft_highpass1_fs64_attention(dat)

cfg = [];
cfg.hpfilter    = 'yes';
cfg.hpfreq      = 1;
cfg.hpfilttype  = 'firws';
cfg.hpfiltdir   = 'onepass-zerophase';
cfg.hpfiltorder = 106;
cfg.hpfiltwintype = 'hamming';
dat             = ft_preprocessing(cfg,dat);