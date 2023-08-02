%> @file  preproc_executepipeline.m
%> @brief Preprocessing pipeline function parser. This function imports the preprocessing pipeline and executes each module.
%> @param pp preprocessing pipeline (stored in a cellstring)
%> @param dat data to be preprocessed. For EEG preprocessing using modules
%> in >eeg folder, the data needs to be in Fieldtrip's format.
%> @param bids_events BIDs events in table format (stored in
% each subject folder (e.g.
% sub-024_ses-02_task-selectiveattention_events.tsv)
%> @param bids_channels BIDs channel information in table format (stored in
% each subject folder (e.g.
% sub-024_ses-02_task-selectiveattention_channels.tsv)

function dat = preproc_executepipeline(pp,dat,bids_events,bids_channels)

global showcomments
if isempty(showcomments)
    showcomments = 1;
end

for i = 1 : numel(pp)
    if showcomments
    fprintf('\n ========================================================================')
    fprintf('\n Executing: %s \n',pp{i})
    end
    fun = str2func(pp{i});
    
    if nargin(fun)==1
    dat = fun(dat);
    else
    dat = fun(dat,bids_events,bids_channels);
    end
end