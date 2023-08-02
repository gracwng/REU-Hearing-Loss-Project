%> @file pp_ft_segmenttrials_attention.m
%> @brief Segment EEG attention data into trials 

%> this function uses <preproc_segment_trials>. The data is segmented from 
% 5 s pre-trial start to 50 s post trial-start

%> history
%> 2019/07/24 updated comments


function dat = pp_ft_segmenttrials_attention(dat,bids_events,bids_channels)

cfg = [];
cfg.events      = bids_events(ismember(bids_events.single_talker_two_talker,{'singletalker','twotalker'}),:);
cfg.offset      = 5;
cfg.duration    = 55;
dat             = preproc_segment_trials(cfg,dat);

