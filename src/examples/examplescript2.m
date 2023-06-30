%> @file  examplescript2.m
%> @brief An example script that demonstrates how one can preprocess
%> audio/EEG data and perform a stimulus-reconstruction analysis with the
%> "mTRF toolbox" [available on "https://sourceforge.net/projects/aespa/"]. 
% This scripts also relies on Fieldtrip and "The Auditory Modeling Toolbox". 

% See:
% Crosse, M. J., Di Liberto, G. M., Bednar, A., & Lalor, E. C. (2016). The multivariate 
% temporal response function (mTRF) toolbox: a MATLAB toolbox for relating neural signals 
% to continuous stimuli. Frontiers in human neuroscience, 10, 604.
%
% S�ndergaard, P. and Majdak, P. (2013). The Auditory Modeling Toolbox.
% The Technology of Binaural Listening, edited by Blauert, J. (Springer, 
% Berlin, Heidelberg), pp. 33-56.
%
% Oostenveld, R., Fries, P., Maris, E., Schoffelen, JM (2011). FieldTrip: 
% Open Source Software for Advanced Analysis of MEG, EEG, and Invasive 
% Electrophysiological Data. Computational Intelligence and Neuroscience, 
% Volume 2011 (2011), Article ID 156869, doi:10.1155/2011/156869



% The goal of this script is not(!!!) to perform the same analysis 
% as the one reported in the paper. 
%
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% The preprocessing pipelines are as follows:
%
% =================
% EEG:
% =================
%   1) Referencing
%   2) Trial segmentation
%   3) Downsampling (to 64 Hz)
%   4) High pass filtering (1 Hz) 
%   5) Lowpass filtering (9 Hz)
%   6) Selection of scalp electrodes 
%   7) Truncation of trials (6-43 s post trigger)
%
%
% =================
% Audio:
% =================
%   1) Averaging across left/right audio channel
%   2) Downsampling (to 12000 Hz)
%   3) Gammatone transformation (with fc ranging between 100 Hz and 4 kHz)
%   3) Full-wave rectificaiton and power-law compression (c=0.3) 
%   4) Averaging across centre frequencies
%   5) Downsampling (to 64 Hz) 
%   4) Bandpass filtering (1-9 Hz) 
%   5) Truncation of trials (6-43 s post trigger)
%
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Matlab version
% 
% You may need a newer version of Matlab (2016b or later) to work with the 
% local functions.  
%
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



clear; clc; close all;

% First, you'll need to point to where the mTRF toolbox is stored and 
% the BIDs directory for the source dataset (bidsdir):
mTRFpath        = '';
bidsdir         =  '../bids/ds-eeg-nhhi';

addpath(mTRFpath)

% We import information about the participants
participants    = readtable(fullfile(bidsdir,'participants.tsv'),'FileType','text','Delimiter','\t','TreatAsEmpty',{'N/A','n/a'});

dataout         = cell(44,1);
for subid = 1 : 44
    
    % The EEG data from each subject is stored in the following folder:
    eeg_dir     = fullfile(bidsdir,sprintf('sub-%0.3i',subid),'eeg');
    
    
    % The EEG data from sub-024 is split into two runs due to a break in the
    % experimental session. For this reason, we ensure that we loop over
    % these two runs for sub-024. For every other subject we do nothing.
    fname_bdf_file  = {};
    fname_events    = {};
    
    fname_bdf_file{1} = fullfile(eeg_dir,sprintf('sub-%0.3i_task-selectiveattention_eeg.bdf',subid));
    fname_events{1} = fullfile(eeg_dir,sprintf('sub-%0.3i_task-selectiveattention_events.tsv',subid));
    
    if subid == 24
        fname_bdf_file{2}     = fullfile(eeg_dir,sprintf('sub-%0.3i_task-selectiveattention_run-2_eeg.bdf',subid));
        fname_events{2}       = fullfile(eeg_dir,sprintf('sub-%0.3i_task-selectiveattention_run-2_events.tsv',subid));
    end
    
    
    
    
    
    % Prepare cell arrays that will contain EEG and audio features
    eegdat      = {};
    audiodat    = {};
    
    % Ensure that the script loops over both of the runs for sub-024
    for run = 1 : numel(fname_bdf_file)
        
        
        % Import the events that are stored in the .bdf EEG file. The
        % bdf_events table also contains information about which of the 
        % audio files that were presented during the EEG experiment. 
        bdf_events = readtable(fname_events{run},'FileType','text','Delimiter','\t','TreatAsEmpty',{'N/A','n/a'});
        
        % Select the rows in the table that points to onset triggers
        % (either onsets of target speech or onset of masker speech)
        bdf_target_masker_events = bdf_events(ismember(bdf_events.trigger_type,{'targetonset','maskeronset'}),:);
        
        
        fprintf('\n Importing data from sub-%0.3i',subid)
        fprintf('\n Preprocessing EEG data')
        
        
        % Preprocess the EEG data according to the proposed preprocessing
        % pipeline. Please inspect <preprocess_eeg> for more details. This
        % function can be found in the bottom of this script
        eegdat{run} = preprocess_eeg(fname_bdf_file{run},bdf_events);
        
       
        fprintf('\n Preprocessing audio data')
       
        
        
        index = 1;
        
        % we will store all of the wav-files in a cell of size (48 x 2) for
        % all subjects except sub-024 which has two runs
        wav_files = cell(sum(strcmp(bdf_target_masker_events.trigger_type,'targetonset')),2);

        for trial = 1 : size(bdf_target_masker_events,1)
            
            [fna,fnb,fnc] = fileparts(bdf_target_masker_events.stim_file{trial});
            
            
            % Import the audio files. Note that we here import audio
            % without CamEQ for the hearing-impaired listeners. 
            audio_type = 'woa'; 
            
            if strcmp(participants.hearing_status{subid},'nh')
                audio_type = '';
            end
            
            % Once this has been done, we can now import all of the audio
            % and store them in the <wav_files> cell.
            fname_audio = fullfile(bidsdir,'stimuli',[fna,'/',fnb,audio_type,fnc]);
            [wav,fsa] =  audioread(fname_audio);
            
            
            if strcmp(bdf_target_masker_events.trigger_type(trial),'maskeronset')
                
                % The row in <bdf_target_masker_events> points to a masker
                % wavfile. 
                
                % Figure out how delayed the masker onset was relative to 
                % the target speech onset. Once this has been done, use this
                % offset to pad the audio with silence. Note that we
                % originally did this in a different way but obtained
                % similar results!
                
                silence = bdf_target_masker_events(trial,:).onset - bdf_target_masker_events(trial-1,:).onset;
                
                % Zero-pad the masker audio with silence
                wav_files{index-1,2} = [zeros(round(silence*fsa),2); wav];
                
            else
                
                % The row in <bdf_target_masker_events> points to a target
                % wavfile. 
                
                if mod(index,5)==0 || index == 1
                    fprintf('\n Importing audio from trial %i',index)
                else
                    fprintf('.')
                end
                % Import the actual target speaker
                wav_files{index,1} = wav;
                
                index = index + 1;
            end
            
        end
        
               
        
        % We have now all of the wavfiles in one single cell. Extract audio
        % features from these wavefiles:
        audiofeat = {};
        
        for trial = 1 : size(wav_files,1)
            
            % Extract the envelope feature for each audio stimuli
            audiofeat{trial,1} =  preprocess_audio(wav_files{trial,1},fsa);
            
            if mod(trial,5)==0 || trial == 1
                fprintf('\n Extracting audio feature from trial %i',trial)
            else
                fprintf('.')
            end
            
            if ~isempty(wav_files{trial,2})
                
                % Do exactly the same thing for envelopes of unattended
                % speech signals
                audiofeat{trial,2} =  preprocess_audio(wav_files{trial,2},fsa);
                
                
            end
            
            
        end
        
        
        % The subseqent audio representations will be stored in <audiodat> 
        % (taking into account the fact that sub-024 has data from two runs).
        audiodat = cat(1,audiodat,audiofeat);
        
    end
    
    

    % Append EEG data from the two runs for sub-024 
    if numel(eegdat)==2
        cfg = [];
        cfg.keepsampleinfo  = 'no';
        eegdat                 = ft_appenddata(cfg,eegdat{1},eegdat{2});
    else
        eegdat = eegdat{1};
    end
    
  
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % Stimulus-response analysis
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    % Train stimulus-reconstruction model. Here, we focus on stimulus
    % reconstruction models with lambda parameters ranging between 10^(-3)
    % and 10^6. The models cover a range of lags ranging between 0 ms post
    % stimulus and 500 ms post stimulus
    
    tmin                    = 0;
    tmax                    = 500;
    fsr                     = 64;
    map                     = -1;
    lambda                  = logspace(-3,6,50);
    
    % Identify which trials that are considered to be single-talker
    
    single_talker_trials    = find(cellfun(@isempty,audiodat(:,2)));
    two_talker_trials       = find(~cellfun(@isempty,audiodat(:,2)));
    
    
    % Store the audio- and EEG- features in cells
    stim_att = cell(1,32);
    stim_itt = cell(1,32);
    resp_st  = cell(1,32);
    stim_st  = cell(1,16);
    resp_st  = cell(1,16);
    
    for ii = 1 : numel(two_talker_trials)
        
        % The envelopes of the attended and unattended speech stream are
        % stored in <stim_att> and <stim_itt> for the two-talker condition
        
        stim_att{1,ii}      = audiodat{two_talker_trials(ii),1};
        stim_itt{1,ii}      = audiodat{two_talker_trials(ii),2};
        
        % Similarly, for the EEG data we store data from the two-talker
        % condition in <resp_tt>
        
        resp_tt{1,ii}       = eegdat.trial{two_talker_trials(ii)}';
        
    end
    
    
    for ii = 1 : numel(single_talker_trials)
        
        % Store envelopes of attended speech in <stim_st> for the
        % single-talker condition
        
        stim_st{1,ii}     = audiodat{single_talker_trials(ii),1};
        
        % Store preprocessed EEG data (64 channels) <resp_st> for the
        % single-talker condition
        
        resp_st{1,ii}     = eegdat.trial{single_talker_trials(ii)}';
    end
    
    % We use a leave-one-trial-out procedure to
    % assess  the stability of the encoding of attended
    % and unattended speech envelopes in the EEG data. For this analysis,
    % we focus on reconstruction models (for clarity)
    
    fprintf('\n Processing data from sub-%0.3i',subid)
    fprintf('\n Fitting and evaluating attended ')
    fprintf('reconstruction models on data from two-talker condition \n')
    [r_att] = mTRFcrossval(stim_att,resp_tt,fsr,map,tmin,tmax,lambda);
    

    fprintf('\n Processing data from sub-%0.3i',subid)
    fprintf('\n Fitting and evaluating unattended ')
    fprintf('reconstruction models on data from two-talker condition \n')
    [r_itt] = mTRFcrossval(stim_itt,resp_tt,fsr,map,tmin,tmax,lambda);
    
    fprintf('\n Processing data from sub-%0.3i',subid)
    fprintf('\n Fitting and evaluating attended ')
    fprintf('reconstruction models on data from single-talker condition \n')
    [r_st]  = mTRFcrossval(stim_st,resp_st,fsr,map,tmin,tmax,lambda);
       
    
    % Store the data in a cellstruct
    dataout{subid} = struct;
    dataout{subid}.r_att = r_att;
    dataout{subid}.r_itt = r_itt;
    dataout{subid}.r_st  = r_st;

    
    
        
    
end


% Results
%
% If we define our goodness-of-fit to be the maximum of the LOO correlation 
% coefficients averaged over all folds, then we could here obtain an array 
% <rr> of size [subject x model type] which will take the following values:
%
%         rr = [];rr(1,1)=0.277976; rr(1,2)=0.235754; rr(1,3)=0.077245; rr(2,1)=0.188490; rr(2,2)=0.222524; rr(2,3)=0.044632; rr(3,1)=0.231513; rr(3,2)=0.206962; rr(3,3)=0.077405; rr(4,1)=0.338648; rr(4,2)=0.274319; rr(4,3)=0.161278; rr(5,1)=0.187724; rr(5,2)=0.157593; rr(5,3)=0.043859; rr(6,1)=0.278606; rr(6,2)=0.235581; rr(6,3)=0.136546; rr(7,1)=0.175976; rr(7,2)=0.125263; rr(7,3)=0.046095; rr(8,1)=0.259098; rr(8,2)=0.197868; rr(8,3)=0.099251; rr(9,1)=0.395324; rr(9,2)=0.297349; rr(9,3)=0.119633; rr(10,1)=0.157031; rr(10,2)=0.165229; rr(10,3)=0.051239; rr(11,1)=0.185685; rr(11,2)=0.147294; rr(11,3)=0.078095; rr(12,1)=0.222996; rr(12,2)=0.222148; rr(12,3)=0.079583; rr(13,1)=0.410487; rr(13,2)=0.356217; rr(13,3)=0.164245; rr(14,1)=0.243203; rr(14,2)=0.213299; rr(14,3)=0.044005; rr(15,1)=0.186055; rr(15,2)=0.155062; rr(15,3)=0.110153; rr(16,1)=0.142613; rr(16,2)=0.100778; rr(16,3)=0.052814; rr(17,1)=0.248547; rr(17,2)=0.226507; rr(17,3)=0.063004; rr(18,1)=0.291103; rr(18,2)=0.291029; rr(18,3)=0.122095; rr(19,1)=0.244902; rr(19,2)=0.218151; rr(19,3)=0.138912; rr(20,1)=0.212761; rr(20,2)=0.199947; rr(20,3)=0.101804; rr(21,1)=0.146623; rr(21,2)=0.098832; rr(21,3)=0.040318; rr(22,1)=0.193377; rr(22,2)=0.183830; rr(22,3)=0.074999; rr(23,1)=0.125666; rr(23,2)=0.109040; rr(23,3)=0.067644; rr(24,1)=0.150191; rr(24,2)=0.141296; rr(24,3)=0.062872; rr(25,1)=0.252336; rr(25,2)=0.193061; rr(25,3)=0.094357; rr(26,1)=0.166188; rr(26,2)=0.153201; rr(26,3)=0.041526; rr(27,1)=0.189409; rr(27,2)=0.192998; rr(27,3)=0.095470; rr(28,1)=0.121941; rr(28,2)=0.098226; rr(28,3)=0.056700; rr(29,1)=0.164597; rr(29,2)=0.167630; rr(29,3)=0.041000; rr(30,1)=0.213847; rr(30,2)=0.205916; rr(30,3)=0.054038; rr(31,1)=0.176583; rr(31,2)=0.168840; rr(31,3)=0.097488; rr(32,1)=0.152523; rr(32,2)=0.109934; rr(32,3)=0.073581; rr(33,1)=0.180740; rr(33,2)=0.172762; rr(33,3)=0.122111; rr(34,1)=0.225331; rr(34,2)=0.178134; rr(34,3)=0.095517; rr(35,1)=0.176712; rr(35,2)=0.132359; rr(35,3)=0.133281; rr(36,1)=0.152612; rr(36,2)=0.089332; rr(36,3)=0.041909; rr(37,1)=0.183081; rr(37,2)=0.176101; rr(37,3)=0.094741; rr(38,1)=0.138674; rr(38,2)=0.115058; rr(38,3)=0.041624; rr(39,1)=0.178113; rr(39,2)=0.157673; rr(39,3)=0.084106; rr(40,1)=0.172571; rr(40,2)=0.151278; rr(40,3)=0.061594; rr(41,1)=0.273537; rr(41,2)=0.215874; rr(41,3)=0.095489; rr(42,1)=0.167949; rr(42,2)=0.161500; rr(42,3)=0.049497; rr(43,1)=0.185932; rr(43,2)=0.136484; rr(43,3)=0.122376; rr(44,1)=0.257857; rr(44,2)=0.228982; rr(44,3)=0.044206;
%         try participants_tsv = ioreadbidstsv(fullfile(bidsdir,'participants.tsv')); catch participants_tsv = load('data_summary.mat'); participants_tsv = participants_tsv.dtab; end
%         nhid = strcmp(participants_tsv.hearing_status,'nh'); hiid = strcmp(participants_tsv.hearing_status,'hi');
%         close all; errorbar(mean(rr(nhid,:)),std(rr(nhid,:))/sqrt(sum(hiid)),'LineWidth',2); hold on; errorbar(mean(rr(hiid,:)),std(rr(hiid,:))/sqrt(sum(hiid)),'LineWidth',2); xlim([0 4]); legend('NH','HI'); set(gca,'xtick',1:3); set(gca,'xticklabel',{'Single-talker','Two-talker (attended)','Two-talker (unattended'});  xtickangle(25); ylabel('Reconstruction accuracy');set(gca,'Fontsize',15); 
%
% 
%
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~








function dat = preprocess_eeg(fname,bdf_events)

% Import the .bdf files
cfg=[];
cfg.channel = 'all';
cfg.dataset = fname;
dat = ft_preprocessing(cfg);


% Re-reference the EEG data
cfg=[];
cfg.reref       = 'yes';
cfg.refchannel  = {'TP8','TP7'};
dat = ft_preprocessing(cfg,dat);


% Define trials and segment EEG data using the events stored in the tsv
% files. Note that we here only focus on the target trials
% http://www.fieldtriptoolbox.org/example/making_your_own_trialfun_for_conditional_trial_definition/
        
bdf_target_events = bdf_events(strcmp(bdf_events.trigger_type,'targetonset'),:);



cfg             = [];
cfg.trl         = [ bdf_target_events.sample-5*dat.fsample, ...                     % start of segment (in samples re 0)
                    bdf_target_events.sample+50*dat.fsample, ...                    % end of segment
                    repmat(-5*dat.fsample,size(bdf_target_events.sample,1),1), ...  % how many samples prestimulus
                    bdf_target_events.value];                                       % store the trigger values in dat.trialinfo
dat             = ft_redefinetrial(cfg,dat);


if sum(sum(isnan(cat(1,dat.trial{:}))))
    error('Warning: For some reason there are nans produced. Please make sure that the trials are not defined to be too long')
end

cfg             = [];
cfg.resamplefs  = 64;
cfg.detrend     = 'no';
cfg.method      = 'resample';
dat             = ft_resampledata(cfg, dat);


% High-pass filter the EEG data
cfg = [];
cfg.hpfilter    = 'yes';
cfg.hpfreq      = 1;
cfg.hpfilttype  = 'but';
dat             = ft_preprocessing(cfg,dat);


% Low-pass filter the EEG data
cfg = [];
cfg.lpfilter    = 'yes';
cfg.lpfreq      = 9;
cfg.lpfilttype  = 'but';
dat             = ft_preprocessing(cfg,dat);

% Select a subset of electrodes
cfg = [];
cfg.channel     = 1:64;
dat             = ft_preprocessing(cfg,dat);


% We only focus on data from 6-s post stimulus onset to 43-s post
% stimulus onset
cfg             = [];
cfg.latency     = [6 43];
dat             = ft_selectdata(cfg, dat);

end






// function feat = preprocess_audio(xx,fs)

// % Define a minimalistic audio preprocessing pipeline. 

// % Average across left/right channels
// xx         = mean(xx,2);

// % Downsample to 12 kHz
// xx         = resample(xx,12000,fs);


// % Pass through a Gammatone filterbank
// flow       = 100;
// fhigh      = 4000;
// fc         = erbspacebw(flow, fhigh);
// [gb, ga]   = gammatone(fc, 12000, 'complex');
// feat       = 2*real(ufilterbankz(gb,ga,xx));


// % Full-wave rectification and power-law compression
// feat       = abs(feat).^0.3;

// % Average across Gammatone filters
// feat       = mean(feat,2);

// % Resample to 64 Hz
// fsr        = 64;
// feat       = resample(feat,fsr,12000);


// % Bandpass filter between 1 Hz and 9 Hz using a Butterworth filter
// [bbp,abp] = butter(2,[1 9]/(fsr/2));
// feat      = filtfilt(bbp,abp,feat);


// % We only focus on data from 6-s post stimulus onset to 43-s post
// % stimulus onset
// feat      = feat(6*fsr:43*fsr,:);

// end




