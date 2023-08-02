%> @file  pp_eeg_bipolareog.m
%> @brief Extract bipolar EOG signal from two left EOG electrodes that were recorded for all subjects

%> 2019/07/16 major: replaced info field with description field

function dat = pp_ft_reref_bipolareog(dat,bids_events,bids_channels)

cfg             = [];
cfg.channel     = find(ismember(bids_channels.description,{'scalp','left_eog_1','left_eog_2'}));
dat             = ft_preprocessing(cfg,dat);

eog_labels      = bids_channels.name(find(ismember(bids_channels.description,{'left_eog_1','left_eog_2'})));


cfg = [];
cfg.channel     = eog_labels;
cfg.reref       = 'yes';
cfg.refchannel  = eog_labels(1);
dat_eog         = ft_preprocessing(cfg,dat);

dat_eog.label{2}= 'EOG';

cfg = [];
cfg.channel     = 'EOG';
dat_eog         = ft_preprocessing(cfg, dat_eog);

dat             = ft_appenddata([],dat, dat_eog);

cfg = [];
cfg.channel     = {'eeg','EOG'};
dat            = ft_preprocessing(cfg, dat);

