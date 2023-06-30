%> @file  build_eeg_features.m
%> @brief Preprocess EEG data from the selective auditory attention experiment.
%> @param subid subject id (1-44)
%> @param pipeline the preprocessing pipeline struct for the EEG data (see workflows_paper.m)
%> @param bidsdir a string indicating the root directory of the BIDs folder
%> @param sdir a string indicating where the data is stored

%> history
%> 2019/07/06 made several lines more readable.  
%> 2019/07/16 major: updated to comply with new BIDs organization 
%> 2019/08/07 made it possible to avoid saving features 

function dat = build_eeg_features(subid,pipeline,bidsdir,sdir)

if nargin < 1 || isempty(subid);    error('Not enough inputs'); end
if nargin < 2 || isempty(pipeline); error('Please define your preprocessing pipeline'); end
if nargin < 3 || isempty(bidsdir);  error('Please specify where the BIDs directory is located'); end
if nargin < 4 || isempty(sdir);     sdir = []; warning('Derived data will not be saved');  end

preproc_greetings(subid,pipeline,bidsdir,sdir)

pp              = pipeline.pp;
ltask           = pipeline.task;

lfname          = fullfile(...
                    bidsdir, ...                     % BIDs root dir
                    sprintf('sub-%0.3i',subid), ...  % subject folder
                    'eeg', ...                       % eeg data folder
                    sprintf('sub-%0.3i_task-%s',subid,ltask)... 
                    ); 

% the .tsv files contains information about EEG channels (e.g. which 
% channels are EOG channels) and information about EEG triggers

bids_events     = ioreadbidstsv([lfname,'_events.tsv']);
bids_channels   = ioreadbidstsv([lfname,'_channels.tsv']);


% import the .bdf data 

cfg = [];
cfg.dataset     = [lfname,'_eeg.bdf'];
cfg.channel     = 'all';
dat             = ft_preprocessing(cfg);


% pass the EEG data through the preprocessing pipeline specified in <pp>

if subid ~= 24 || ~strcmp(ltask,'selectiveattention')
    dat     = preproc_executepipeline(pp,dat,bids_events,bids_channels);
end




% since sub024 had data split into two sessions, we need to concatenate
% data from the two sessions. this is done using the subroutine
% <io_concatenateeegdata>

if subid == 24 && strcmp(ltask,'selectiveattention')
    dat = io_concatenateeegdata(subid,pp,dat,bids_events,bids_channels,bidsdir,ltask);
end


if ~isempty(sdir) 
fprintf('\n data has now been preprocessed and will be stored in the following folder:')
fprintf('\n "%s"',fullfile(sdir,'features','eeg'))

if ~exist(fullfile(sdir,'features','eeg'))
    mkdir(fullfile(sdir,'features','eeg'))
end

save(fullfile(sdir,'features','eeg',sprintf('sub-%0.3i_eeg-%s.mat',subid,pipeline.sname)),'dat')
end


end





function [dat, bids_events] = io_concatenateeegdata(subid,pp,dat,bids_events,bids_channels,bidsdir,ltask)
    
    % do the exact same thing as before, but import data from session 2
    % instead. once the data has been imported, pass the new data through
    % the similar preprocessing pipeline and stop when the routine
    % <pp_ft_appenddatafromsessions_attention> appears. Then concatenate
    % the data temporally and execute the last couple of preprocessing
    % steps
    
    lfname_s2     = fullfile(...
                    bidsdir, ...                     % BIDs root dir
                    sprintf('sub-%0.3i',subid), ...  % subject folder
                    'eeg', ...                       % eeg data folder
                    sprintf('sub-%0.3i_task-%s_run-2',subid,ltask)... 
                    ); 
   
    bids_events_s2      = ioreadbidstsv([lfname_s2,'_events.tsv']);
    bids_channels_s2    = ioreadbidstsv([lfname_s2,'_channels.tsv']);

    
    cfg = [];
    cfg.dataset         = [lfname_s2,'_eeg.bdf'];
    cfg.channel         = 'all';
    dat_s2              = ft_preprocessing(cfg);
    
    pid                 = find(strcmp(pp,'pp_ft_appenddatafromsessions_attention'));
    
    dat                 = preproc_executepipeline(pp(1:pid-1),dat,   bids_events,    bids_channels);
    dat_s2              = preproc_executepipeline(pp(1:pid-1),dat_s2,bids_events_s2, bids_channels_s2);
    
    % temporally concatenate data and update the <bids_events> table. note
    % that the <bids_channels> table is the same for the two sesssions, so
    % this does not need to be updated
    
    cfg = [];
    cfg.keepsampleinfo  = 'no';
    dat                 = ft_appenddata(cfg,dat,dat_s2);
    bids_events         = [bids_events; bids_events_s2];
    

    dat                 = preproc_executepipeline(pp((pid+1):end),dat,bids_events,bids_channels);   
end
