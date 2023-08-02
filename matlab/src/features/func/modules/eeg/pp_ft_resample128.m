%> @file pp_ft_resample128.m
%> @brief Resample EEG data to 128 Hz

function dat = pp_ft_resample128(dat)

cfg             = [];
cfg.resamplefs  = 128;
cfg.detrend     = 'no';
cfg.method      = 'resample';
dat             = ft_resampledata(cfg, dat);