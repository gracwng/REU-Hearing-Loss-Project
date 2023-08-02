%> @file pp_ft_segmenttrials_efr.m
%> @brief Segment EEG data from EFR experiment into trials 

%> this function uses <preproc_segment_trials>. The data is segmented from
%> 3 s pre-trial start to 5 s post trial-start. The triggers of interest are 
%> here <stimonset_delta_gamma> and <stimonset_gamma>

%> history
%> 2019/07/24 updated comments

function dat = pp_ft_segmenttrials_efr(dat,bids_events,bids_channels)

cfg = [];
cfg.events      = bids_events(ismember(bids_events.trigger_type,{'stimonset_delta_gamma','stimonset_gamma'}),:);
cfg.offset      = 3;
cfg.duration    = 8;
dat             = preproc_segment_trials(cfg,dat);