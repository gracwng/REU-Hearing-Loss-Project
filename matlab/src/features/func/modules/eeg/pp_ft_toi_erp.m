%> @file pp_ft_toi_erp.m
%> @brief Truncate ERP data from each trial from -0.1 s to 0.4 s post trigger

function dat = pp_ft_toi_erp(dat)

cfg             = [];
cfg.latency     = [-0.1 0.4];
dat             = ft_selectdata(cfg, dat);
