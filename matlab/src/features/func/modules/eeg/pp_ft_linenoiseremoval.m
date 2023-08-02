%> @file  pp_ft_linenoiseremoval.m
%> @brief Line noise removal using a notch FFT-based filtering approach

function dat = pp_ft_linenoiseremoval(dat)

cfg = [];
cfg.dftfilter   = 'yes';
cfg.dftfreq     = [50 100 150];
cfg.dftreplace  = 'zero'
dat = ft_preprocessing(cfg,dat);