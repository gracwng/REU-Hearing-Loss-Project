%> @file  evaluate_itpc.m
%> @brief Compute ITPC for the EFR data using Fieldtrip. 
%> @param subid subject id (an integer between 1 and 44)
%> @param pipeline_eeg the preprocessing pipeline struct for the eeg (see workflows_paper.m)
%> @param sdir where was the derived features stored and where will the results be stored?


function evaluate_itpc(subid,pipeline_eeg,sdir)

rng('default'); parcreaterandstream(44, randi(10000)+subid)


load(fullfile(sdir,'features','eeg',sprintf('sub-%0.3i_eeg-%s.mat',subid,pipeline_eeg.sname)))



itc_cond = {};
foihz = 1:0.5:60;

for ff = 1 : numel(foihz)
    trigs = [192 224];
    for k = 1 : 2
        cfg = [];
        cfg.method      = 'wavelet';
        cfg.toi         = -3:1/dat.fsample*2:5;
        cfg.foi         = foihz(ff);
        cfg.trials      = find(dat.trialinfo==trigs(k));
        cfg.output      = 'fourier';
        cfg.channel     = 'EEG';
        cfg.pad         = 'maxperlen';
        cfg.width       = 12;
        
        freq = ft_freqanalysis(cfg, dat);
        
        itc = [];
        itc.label     = freq.label;
        itc.freq      = freq.freq;
        itc.time      = freq.time;
        itc.dimord    = 'chan_freq_time';
        
        F = freq.fourierspctrm;   % copy the Fourier spectrum
        N = size(F,1);           % number of trials
        
        % compute inter-trial phase coherence (itpc)
        itc.itpc      = F./abs(F);         % divide by amplitude
        itc.itpc      = nansum(itc.itpc,1);   % sum angles
        itc.itpc      = abs(itc.itpc)/N;   % take the absolute value and normalize
        itc.itpc      = squeeze(itc.itpc); % remove the first singleton dimension
        
        itc_cond{k,ff} = itc;
    end
end


    
if ~exist(fullfile(sdir,'results'))
    mkdir(fullfile(sdir,'results'))
end


save(fullfile(sdir,'results',sprintf('sub-%0.3i_itpc_%s-%s.mat',subid,pipeline_eeg.task,pipeline_eeg.sname)),'itc_cond')
end

