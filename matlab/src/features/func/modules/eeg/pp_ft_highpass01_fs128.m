%> @file  pp_ft_highpass01_fs128.m
%> @brief Highpass 128 Hz digitized EEG data at 0.1 Hz using a 2112 order FIR filter

function dat = pp_ft_highpass01_fs128(dat)

cfg             = [];
cfg.hpfilter    = 'yes';
cfg.hpfreq      = 0.1;
cfg.hpfilttype  = 'firws';
cfg.hpfiltdir   = 'onepass-zerophase';
cfg.hpfiltorder = 2112;
cfg.hpfiltwintype = 'hamming';
dat             = ft_preprocessing(cfg,dat);