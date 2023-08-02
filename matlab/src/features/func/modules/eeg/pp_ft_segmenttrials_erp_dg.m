%> @file pp_ft_segmenttrials_erp_dg.m
%> @brief Segment EEG data from EFR experiment using the same approach as for ERP data. 
% This is segmented into trials using <preproc_segment_trials>. The data is segmented from 1 s pre-trial start to 1 s post
%trial-start. The triggers of interest are here <stimonset_delta_gamma> and
%<stimonset_gamma>


%> history
%> 2019/07/24 updated comments


function dat = pp_ft_segmenttrials_erp_dg(dat,bids_events,bids_channels)

cfg = [];
cfg.events      = bids_events(ismember(bids_events.trigger_type,{'stimonset_delta_gamma','stimonset_gamma'}),:);
cfg.offset      = 1;
cfg.duration    = 2;
dat             = preproc_segment_trials(cfg,dat);