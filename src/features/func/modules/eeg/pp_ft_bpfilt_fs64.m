%> @file  pp_ft_bpfilt_fs64.m
%> @brief Bandpass filter EEG data with consecutive highpass filtering
%> and lowpass filtering. 
%
%> history:
%> 2019/07/24 this function has not yet been used


function dat = pp_ft_bpfilt_fs64(dat)

global fbp


cfg = [];
cfg.hpfilter    = 'yes';
cfg.hpfreq      = fbp(1);
cfg.hpfilttype  = 'firws';
cfg.hpfiltdir   = 'onepass-zerophase';
cfg.hpfiltwintype = 'hamming';
dat             = ft_preprocessing(cfg,dat);


cfg = [];
cfg.lpfilter    = 'yes';
cfg.lpfreq      = fbp(2);
cfg.lpfilttype  = 'firws';
cfg.lpfiltdir   = 'onepass-zerophase';
cfg.lpfiltwintype = 'hamming';
dat             = ft_preprocessing(cfg,dat);

end