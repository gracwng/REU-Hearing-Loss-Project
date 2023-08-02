%> @file pp_ft_lowpass30_fs512.m
%> @brief Lowpass 512 Hz digitized EEG data at 30 Hz using a 226th order FIR filter

function dat = pp_ft_lowpass30_fs512(dat)

cfg = [];
cfg.lpfilter    = 'yes';
cfg.lpfreq      = 30;
cfg.lpfilttype  = 'firws';
cfg.lpfiltdir   = 'onepass-zerophase';
cfg.lpfiltorder = 226;
cfg.lpfiltwintype = 'hamming';
dat = ft_preprocessing(cfg,dat);
end