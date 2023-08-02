%> @file pp_ft_resample64.m
%> @brief Resample EEG data to 64 Hz

function dat = pp_ft_resample64(dat)

cfg             = [];
cfg.resamplefs  = 64;
cfg.detrend     = 'no';
cfg.method      = 'resample';
dat             = ft_resampledata(cfg, dat);