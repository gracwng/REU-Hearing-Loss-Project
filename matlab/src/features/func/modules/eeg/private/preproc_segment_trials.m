%> @file preproc_segment_trials.m
%> @brief Segments Fieldtrip data using ft_definetrial and specified data segments of interest
%> @param cfg configuration structure
%> @param cfg.offset (i.e. pretrig) number of seconds before each trigger that 
%> should be kept in each trial. For example, if cfg.offset = 2 then
%> the trial will begin 2-s before the trigger event
%> @param cfg.duration duration of trials in seconds. if cfg.offset = 2 and
%> cfg.duration = 5 then the segments will begin 2 s before trigger events
%> and stop 3 s after trigger events
%> @param cfg.events events table (e.g. BIDs table; see e.g. the
%> <task-selectiveattention_events.json>) which should contain the following
%> fields:
%> @param cfg.events.onset onset time of trigger in seconds relative to 0
%> @param cfg.events.value trigger value (e.g. 192 or 224)
%> @param dat fieldtrip data structure before(!!!) segmentation. Since this
%> structure has not yet been segmented we focus on dat.trial{1}

%> keep in mind that:
%> trl(:,1) = start of segment
%> trl(:,2) = end of segment
%> trl(:,3) = how many samples prestimulus
%> trl(:,4) = this will add the cfg.events.value to the output data
%> structure (dat.trialinfo)

%> for more examples:
%> http://www.fieldtriptoolbox.org/example/making_your_own_trialfun_for_conditional_trial_definition/

%> history
%> 2019/07/24 updated comments

function dat = preproc_segment_trials(cfg,dat)


trl = [];
for i = 1 : size(cfg.events,1)
    [~,onsetsamples] = min(abs(cfg.events.onset(i)-dat.time{1}));
    trl(i,1) = onsetsamples-cfg.offset * dat.fsample;
    
    trl(i,2) = trl(i,1) + cfg.duration*dat.fsample;
    
    trl(i,3) =  -cfg.offset * dat.fsample; 

    trl(i,4) =  cfg.events.value(i); 
end


cfg     = [];
cfg.trl = trl;
dat    = ft_redefinetrial(cfg,dat);




end
