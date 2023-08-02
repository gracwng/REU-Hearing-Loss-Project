%> @file  build_aud_features.m
%> @brief This function can be used to preprocess the derived audio
%> features stored in the Zenodo dataset.
%> @param subid subject id (e.g. 1)
%> @param pp the preprocessing pipeline 
%> @param bidsdir root directory of the BIDs folder
%> @param cameq ['wa'/'woa'/'woacontrol'] 



function aud_feat = build_aud_features_from_derivatives(subid,pp,bidsdir,cameq)

if nargin < 1 || isempty(subid); subid = 1; end
if nargin < 2 || isempty(pp)
    pp     =   {'pp_aud_lowpass30_512',...
        'pp_aud_resample64_512',...
        'pp_aud_highpass1_64',...
        'pp_aud_lowpass9_64',...
        'pp_aud_toi_attention'};
end
if nargin < 3 || isempty(bidsdir); bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end
if nargin < 4 || isempty(cameq);   cameq = 'woa'; end


% The CamEQ functionality is not updated yet
if ~any([strcmp(cameq,'woa') strcmp(cameq,'wa')])
error('The requested features is not available')
end


% Greet the user
pipeline = struct;
pipeline.sname = '';
pipeline.pp = pp;
sdir = '';
preproc_greetings(subid,pipeline,bidsdir,sdir)



% Import events in EEG dataset from BIDS dataset
fname           = fullfile(bidsdir,sprintf('sub-%0.3i',subid),'eeg',sprintf('sub-%0.3i_task-%s_events.tsv',subid,'selectiveattention'));
bids_events     = readtable(fname,'FileType','text','Delimiter','\t','TreatAsEmpty',{'N/A','n/a'});
participants    = readtable(fullfile(bidsdir,'participants.tsv'),'FileType','text','Delimiter','\t','TreatAsEmpty',{'N/A','n/a'});

if subid == 24
    fname           = fullfile(bidsdir,sprintf('sub-%0.3i',subid),'eeg',sprintf('sub-%0.3i_task-%s_run-2_events.tsv',subid,'selectiveattention'));
    bids_events     = [bids_events; ...
        readtable(fname,'FileType','text','Delimiter','\t','TreatAsEmpty',{'N/A','n/a'})];
end

bids_events     = bids_events(ismember(bids_events.trigger_type,{'targetonset','maskeronset'}),:);


% Detect which of these events that correspond to onset of target or masker
id_target       = find(strcmp(bids_events.trigger_type,'targetonset'));
id_masker       = find(strcmp(bids_events.trigger_type,'maskeronset'));



% Prepare the output struct
aud_feat                            = struct;
aud_feat.target                     = cell(1,48);
aud_feat.masker                     = cell(1,48);
aud_feat.time                       = cell(2,48);
aud_feat.wavname                    = cell(2,48);
aud_feat.attend_left_right          = cell(1,48);
aud_feat.single_talker_two_talker   = cell(1,48);
aud_feat.attend_male_female         = cell(1,48);



% Fill it up
if strcmp(cameq,'woa')
    aud_feat.wavname(1,:)                               = bids_events.stim_file_without_cambridge_eq(id_target);
    aud_feat.wavname(2,ismember(id_target,id_masker-1)) = bids_events.stim_file_without_cambridge_eq(id_masker);
else
    aud_feat.wavname(1,:)                               = bids_events.stim_file(id_target);
    aud_feat.wavname(2,ismember(id_target,id_masker-1)) = bids_events.stim_file(id_masker);
end


aud_feat.attend_left_right        = num2cell(bids_events.attend_left_right(id_target));
aud_feat.single_talker_two_talker = num2cell(bids_events.single_talker_two_talker(id_target));
aud_feat.attend_male_female       = num2cell(bids_events.attend_male_female(id_target));



fprintf('\n Importing an processing data')




% Lets preproces the audio data
global showcomments
showcomments = 0;

for t = 1 : 48
    
    fprintf('\n Data imported from trial %i',t)
    
    for mt = 1 : 2
        
        if ~cellfun(@isempty,aud_feat.wavname(mt,t))
            
            
            fname = fullfile(bidsdir,'derivatives','stimuli',aud_feat.wavname{mt,t});
            [fdir,fn] = fileparts(fname);
            load([fdir,'/',fn,'.mat'])
            
            
            
            dat    = preproc_executepipeline(pp,dat);
            
            if mt == 1
                aud_feat.target{1,t} = dat.feat;
                aud_feat.time{1,t}   = dat.t;
            else
                aud_feat.masker{1,t} = dat.feat;
                aud_feat.time{2,t}   = dat.t;
            end
        end
    end
end







fprintf('\n ================================= \n')



try
    identical_time_axes = [];
    if size(aud_feat.time,1) == 2
        for t = 1 : 48
            if ~cellfun(@isempty,aud_feat.time(2,t))
                
                if any(aud_feat.time{1,t}~=aud_feat.time{2,t})
                    identical_time_axes = cat(1,identical_time_axes,0);
                else
                    identical_time_axes = cat(1,identical_time_axes,1);
                end
            end
        end
    end
    
    if ~any(identical_time_axes~=1)
        fprintf('\n It is assumed that features are aligned in time')
        aud_feat.time = aud_feat.time(1,:);
    else
        warning('Features are not aligned in time')
    end
end




end