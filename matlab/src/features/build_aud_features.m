%> @file  build_aud_features.m
%> @brief Preprocess audio data from the selective auditory attention 
%> experiment.
%> @param subid subject id (1-44)
%> @param pipeline the preprocessing pipeline struct for the audio 
%> (see workflows_paper.m)
%> @param bidsdir a string indicating the root directory of the BIDs folder
%> @param sdir a string indicating where the data is stored
%> @param cameq ['wa'/'woa'/'woacontrol'] (with/without CamEQ). 
%> [cameq = 'woa' (default)]: focus on audio without Cambridge 
%> equalization (here obtained via inverse filtering),
%> [cameq = 'wa']: focus on audio with Cambridge amplification, 
%> [cameq = 'woacontrol'] = focus on audio without Cambridge equalization 
%> (here obtained by loudness matching before CamEQ and leaving out CamEQ)
%> @param timealigned [0/1 (default)]. the scripts contained in >src>paper
%> and >src>examples>examplescript2.m assumes that the audio features of
%> target/masker pairs are aligned in time (this is achieved using a
%> "pp_aud_toi_attention", please inspect this file). by setting 
%> [timealigned=1] the target/masker features are assumed to share a time 
%> vector. whenever this is not the case, set [timealigned=0], in which
%> case the output will contain a time vector both for the target and masker

%> @retval feat struct contained derived features
%> @retval feat.wavname cellstring that points to the raw audio files
%> @retval feat.target features of target audio streams
%> @retval feat.masker features of masker audio streams. empty cells will
%> relate to single-talker trials (in which cases there were no competing
%> speaker)
%> @retval feat.time time vectors for each trial. if [timealigned=0] there 
%> will be two rows in the cell. the first row will here relate to the
%> target speaker and the second to the masker speaker
%> @retval feat.attend_left_right cellstrings indicating whether the target
%> speaker was lateralized to the left or to the right
%> @retval feat.single_talker_two_talker cellstrings indicating if it was a
%> single-talker trial or two-talker trial



function feat = build_aud_features(subid,pipeline,bidsdir,sdir,cameq,timealigned)

if nargin < 1 || isempty(subid);          error('Not enough inputs'); end
if nargin < 2 || isempty(pipeline);       error('Please define your preprocessing pipeline'); end
if nargin < 3 || isempty(bidsdir);        error('Please specify where the BIDs directory is located'); end
if nargin < 4 || isempty(sdir);           sdir = []; warning('Derived data will not be saved');  end
if nargin < 5 || isempty(cameq);          cameq = 'woa'; end
if nargin < 6 || isempty(timealigned);    timealigned = 1; end


preproc_greetings(subid,pipeline,bidsdir,sdir)


pp              = pipeline.pp;
ltask           = pipeline.task;

                
bids_events     = ioreadbidstsv(...
                    fullfile(bidsdir,...
                         sprintf('sub-%0.3i',subid), ...
                         'eeg', ...
                         sprintf('sub-%0.3i_task-%s_events.tsv',subid,ltask)));
participants    = ioreadbidstsv(fullfile(bidsdir,'participants.tsv'));


% the data from <sub-024> was stored in two separate runs. the following
% function ensures that the two .tsv files in the two
% runs are concatenated properly. 

if subid == 24
bids_events     = io_cat_tsv_runs(subid,bidsdir,ltask,bids_events);
end

% the <bids_events> table contains information about the onset of the
% target stimulus and the masker stimulus. moreover, this table contains 
% information about which trials that are single-talker trials and which 
% that are two-talker trials. we take these events and exclude everything 
% that is not related to the trial-onsets. in addition to this, we define 
% a new vector called <offset> which is 0 for all target onsets but larger 
% than zero for masker onsets (i.e. how delayed is the masker relative to 
% the target).
% 
% this <offset> vector is used to align the target and masker audio such 
% that their time axes always are relative to trial onset. see
% <io_extract_audio_events> for more details.

[bids_events,n_trials,offset] = io_extract_audio_events(bids_events);


% prepare the output struct:

feat            = struct;
feat.target     = cell(1,n_trials);                 % derived feature of the target speaker in each of the 48 trials (time x dim)
feat.masker     = cell(1,n_trials);                 % derived feature of the masker speaker in each of the 48 trials (time x dim)
feat.time       = cell(1,n_trials);                 % corresponding time vectors
feat.wavname    = cell(2,n_trials);                 % a (2x48) cellstring where the first row contains names of the target wavfile and the second row contains names of the masker wavfiles
feat.attend_left_right = cell(1,n_trials);          % a (1x48) cellstring where each entry either is "attendleft" or "attendright", indicating whether the subject was attending a speaker on the left or the right ear
feat.single_talker_two_talker = cell(1,n_trials);   % a (1x48) cellstring where each entry either is "singletalker" or "twotalker", indicating whether or not it was a single-talker trial or a two-talker trial
feat.attend_male_female = cell(1,n_trials);         % a (1x48) cellstring where each entry either is "attendmale" or "attendfemale", indicating whether the subject was focusing on the male of female talker



% loop over all entries in the bids_events table and fill up <feat>. 
it = 1;
for i = 1 : size(bids_events,1)
    
    
    wavname = fullfile(bidsdir, ...
                       'stimuli', ...
                       bids_events.stim_file{i});
    
    % if cameq is specified to be 'woa' or 'woacontrol' then add the string 
    % to the wavname such that t001.wav becomes t001woa.wav og
    % t001woacontrol.wav
    
    if any([strcmp(cameq,'woa') strcmp(cameq,'woacontrol')]) && strcmp(participants.hearing_status(subid),'hi')
       [w1,w2,w3] = fileparts(wavname);
       wavname = [w1,'/',w2,cameq,w3];
    end


    [dat,fs]= audioread(wavname);
    
    dx = struct;
    dx.feat = dat;
    dx.fs = fs;
    dx.t  = [0:1/dx.fs:size(dat,1)/dx.fs-1/dx.fs]';
    
    % the time vector <dx.t> is relative to target speaker onset! so
    % dx.t(1)=0 for the target speaker. however,  since the masker is onset 
    % later than the target speaker we define the time vector of the masker
    % relative to target onset (i.e. dx.t(1) = masker-to-target-offset). 
    % this allows us to align the features in time 
    % (note that we previously did this in a slightly different way but we 
    % obtain the same results!)    
    if offset(i)~=0
        dx.t  = dx.t + offset(i);
    end
    
    
    dat    = preproc_executepipeline(pp,dx);


    % fill up the <feat> struct. we do so by adding the preprocessed audio
    % <dat> into <feat.target> and <feat.masker>. Note that the masker 
    % always is presented after a target. Therefore, we fill up 
    % <feat.masker> at <it-1> and only increase <it> after a "targetonset" 
    % event.
    %
    
    % When timealigned = 1, we assume that the target and masker are
    % aligned in time. The time vector for the target and the masker will
    % thus be identical. This is e.g. the case when including 
    % <pp_aud_toi_attention>. In this case "size(feat.time) = [44x1]"
    
    if strcmp(bids_events.trigger_type(i),'targetonset')
        feat.target{1,it}                   = dat.feat;
        feat.wavname{1,it}                  = wavname;
        feat.attend_left_right{1,it}        = bids_events.attend_left_right(i);
        feat.single_talker_two_talker{1,it} = bids_events.single_talker_two_talker(i);
        feat.attend_male_female{1,it}       = bids_events.attend_male_female(i);
        
        if timealigned == 1
            feat.time{it} = dat.t;
        elseif timealigned == 0
            feat.time{1,it} = dat.t;
        end
        it = it + 1;
    else
        feat.masker{1,it-1}                 = dat.feat;
        feat.wavname{2,it-1}                = wavname;
        
        if timealigned==0
            feat.time{2,it-1} = dat.t;
        end
    end
    
    % to better understand the logic try to look at the following example:
    % i   bids_events.trigger_type         it        bids_events.single_talker_two_talker
    % -----------------------------------------------------------------------------
    % 1  'targetonset'                     1       'singletalker'
    % 2  'targetonset'                     2       'twotalker'
    % 3  'maskeronset'                     2       'n/a'
    % 4  'targetonset'                     3       'twotalker'
    % 5  'maskeronset'                     3       'n/a'
    % 6  'targetonset'                     4       'twotalker'
    % 7  'maskeronset'                     4       'n/a'
    % 8  'targetonset'                     5       'singletalker'
    % 9  'targetonset'                     6       'twotalker'
    %
    % which subsequently yields:
    %
    %         feat.masker(1:5)
    %             ans =
    %                 {0x0 double}    {2369x1 double}    {2369x1 double}    {2369x1 double}    {0x0 double}
    %         feat.target(1:5)
    %             ans =
    %                 {2369x1 double}    {2369x1 double}    {2369x1 double}    {2369x1 double}    {2369x1 double}
end

if ~isempty(sdir) 
fprintf('\n data has now been preprocessed and will be stored in the following folder:')
fprintf('\n "%s"',fullfile(sdir,'features','aud'))

if ~exist(fullfile(sdir,'features','aud'))
    mkdir(fullfile(sdir,'features','aud'))
end


save(fullfile(sdir,'features','aud',sprintf('sub-%0.3i_aud-%s-%s.mat',subid,pipeline.sname,cameq)),'feat')
end

end













function bids_events = io_cat_tsv_runs(subid,bidsdir,ltask,bids_events)

% this function simply takes .tsv files for subject 24 and concatenate them

if subid == 24 && strcmp(ltask,'selectiveattention')

    lname_run_2              = fullfile(bidsdir,...
                                 sprintf('sub-%0.3i',subid), ...
                                 'eeg', ...
                                 sprintf('sub-%0.3i_task-%s_run-2_events.tsv',subid,ltask));
                                 
    % now concatenate the bids events across the two runs
    bids_events       = [bids_events; ioreadbidstsv(lname_run_2)];
else
end
  
end




function [bids_events,n_trials,offset] = io_extract_audio_events(bids_events)

% this function is used to prepare the so-called <offset> vector. this
% vector indicates how much a masker is delayed in time relative to trial 
% onset. for target speech onset events this will therefore be zero. 

offset          = [0; diff(bids_events.onset)];

% we're only interested in target and masker events as these indicate when 
% in time the target and masker audio were played.

stim_events     = ismember(bids_events.trigger_type,{'targetonset','maskeronset'});
bids_events     = bids_events(stim_events,:);
offset          = offset(stim_events);

% by definition, we set all <offset> entries corresponding to target onsets
% to 0 s.

offset(strcmp(bids_events.trigger_type,'targetonset')) = 0;

% finally, compute the number of trials (this will be 48)

n_trials        = sum(ismember(bids_events.trigger_type,{'targetonset'}));

% =========================================================================
% to better understand what this function does, please see the following:
%
% suppose that we input a table of the following format:
%
%     onset     duration      sample          type         value    trigger_type 
%     ______    ________    __________    _____________    _____    _____________
% 
%          0      NaN                1    'STATUS'          128     'n/a'        
%          0      NaN                1    'Epoch'           NaN     'n/a'        
%          0      NaN                1    'CM_in_range'     NaN     'n/a'        
%     37.898      NaN            19405    'STATUS'          224     'targetonset'
%     87.887      NaN            44999    'STATUS'          131     'trialend'   
%      145.9      NaN            74703    'STATUS'          254     'targetonset'
%     195.89      NaN        1.003e+05    'STATUS'          131     'trialend'   
%     267.04      NaN       1.3672e+05    'STATUS'          224     'targetonset'
%     317.03      NaN       1.6232e+05    'STATUS'          131     'trialend'   
%     374.92      NaN       1.9196e+05    'STATUS'          240     'targetonset'
%     378.82      NaN       1.9396e+05    'STATUS'          137     'maskeronset'
%      426.9      NaN       2.1858e+05    'STATUS'          131     'trialend'   
%     490.62      NaN        2.512e+05    'STATUS'          254     'targetonset'
%     540.61      NaN        2.768e+05    'STATUS'          131     'trialend'   
%      598.5      NaN       3.0644e+05    'STATUS'          240     'targetonset'
%     602.54      NaN        3.085e+05    'STATUS'          137     'maskeronset'
%     648.49      NaN       3.3203e+05    'STATUS'          131     'trialend'   
%     708.19      NaN       3.6259e+05    'STATUS'          255     'targetonset'
%     711.73      NaN        3.644e+05    'STATUS'          137     'maskeronset'
%     763.97      NaN       3.9115e+05    'STATUS'          131     'trialend'   
%
%
% the output from this function will then be:
%
%     onset     duration      sample        type      value    trigger_type 
%     ______    ________    __________    ________    _____    _____________
% 
%     37.898      NaN            19405    'STATUS'     224     'targetonset'
%      145.9      NaN            74703    'STATUS'     254     'targetonset'
%     267.04      NaN       1.3672e+05    'STATUS'     224     'targetonset'
%     374.92      NaN       1.9196e+05    'STATUS'     240     'targetonset'
%     378.82      NaN       1.9396e+05    'STATUS'     137     'maskeronset'
%     490.62      NaN        2.512e+05    'STATUS'     254     'targetonset'
%      598.5      NaN       3.0644e+05    'STATUS'     240     'targetonset'
%     602.54      NaN        3.085e+05    'STATUS'     137     'maskeronset'
%     708.19      NaN       3.6259e+05    'STATUS'     255     'targetonset'
%     711.73      NaN        3.644e+05    'STATUS'     137     'maskeronset'
%
% and the offset vector will be:
%          0
%          0
%          0
%          0
%     3.8926    (i.e. the onset of the masker is 3.8926 s after the onset of the target)
%          0
%          0
%     4.0391    (i.e. round(4.0391) == round(602.54 - 598.5))
%          0
%     3.5371    (i.e. round(3.5371) == round(711.73 - 708.19))
% =========================================================================

end