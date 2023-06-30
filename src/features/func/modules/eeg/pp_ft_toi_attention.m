%> @file pp_ft_toi_attention.m
%> @brief Truncate EEG data from the attention experiment in each trial from 6 s to 43 s post trigger

function dat = pp_ft_toi_attention(dat)

cfg             = [];
cfg.latency     = [6 43];
dat             = ft_selectdata(cfg, dat);
