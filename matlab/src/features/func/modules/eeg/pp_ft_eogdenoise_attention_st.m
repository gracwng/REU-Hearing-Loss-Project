%> @file  pp_ft_eogdenoise_attention_st.m
%> @brief Denoise EEG data using <preproc_eogdenoise>, but does so only with a denoising filter trained on single-talker data

function dat = pp_ft_eogdenoise_attention_st(dat,bids_events,bids_channels)


all_trials           = ismember(bids_events.single_talker_two_talker,{'singletalker','twotalker'});

events_all_trials    = bids_events(all_trials,:);

single_talker_trials = find(ismember(events_all_trials.single_talker_two_talker,{'singletalker'}));


cfg =[];
cfg.trials          = single_talker_trials;
dat_single_talker   = ft_preprocessing(cfg,dat);


cfg             = [];
cfg.demean      = 1;
cfg.zthresh     = 4;
cfg.eogchan     = {'EOG','Fp1','Fpz','Fp2'};
cfg.pthresh     = 0.8;
cfg.artseg      = [];
[out,~]         = preproc_eogdenoise(cfg,dat_single_talker);



for tt = 1 : numel(dat.trial)
    dat.trial{tt} = bsxfun(@minus,dat.trial{tt}',out.mu)';   
    dat.trial{tt} = bsxfun(@plus,dat.trial{tt}'-dat.trial{tt}'*out.wd,out.mu)';
end

end