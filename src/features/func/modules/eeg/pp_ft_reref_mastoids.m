%> @file pp_ft_reref_mastoids.m
%> @brief Rereference EEG data to the average response across TP8 and TP7

function dat = pp_ft_reref_mastoids(dat)

cfg = [];
cfg.reref       = 'yes';
cfg.refchannel  = {'TP8','TP7'};
dat = ft_preprocessing(cfg,dat);
