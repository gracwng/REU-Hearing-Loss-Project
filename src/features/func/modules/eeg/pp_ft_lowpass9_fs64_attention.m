%> @file  pp_ft_lowpass9_fs64_attention.m
%> @brief Lowpass 64 Hz digitized EEG data at 9 Hz using a 94th order FIR filter

%> history: 
%> 2019/08/07 order fix in naming (did not affect results)

function dat = pp_ft_lowpass9_fs64_attention(dat)

cfg = [];
cfg.lpfilter    = 'yes';
cfg.lpfreq      = 9;
cfg.lpfilttype  = 'firws';
cfg.lpfiltdir   = 'onepass-zerophase';
cfg.lpfiltorder = 94;
cfg.lpfiltwintype = 'hamming';
dat             = ft_preprocessing(cfg,dat);
