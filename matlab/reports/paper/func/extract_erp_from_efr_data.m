%> @file  extract_erp_from_efr_data.m
%> @brief Export N1 amplitides of ERPs extracted from delta-gamma and gamma stimuli

%> history
%> 2019/07/08 added comments and doplot option

function dtab = extract_erp_from_efr_data(sdir,bidsdir,pipeline_dg_erp)

if nargin < 1 || isempty(sdir);     sdir    = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/'; end
if nargin < 2 || isempty(bidsdir);  bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end

% import the BIDs events file which contains information about each
% participant and their hearing status (<nh> or <hi>)
participants_tsv = ioreadbidstsv(fullfile(bidsdir,'participants.tsv'));

% for the statistical analysis of the encoding accuracies we average the
% accuracies over a cluster of fronto-central electrodes. these correspond
% to the following columns in the data summaries
roi     = [4 5 6 9 10 11 39 40 41 44 45 46  38 47];

for subid = 1 : 44
    
    % import the data from each subject
    fprintf('\n proccesing data from subject %i of %i',subid,44)
    clear dat
    fname = fullfile(sdir,'features','eeg',sprintf('sub-%0.3i_eeg-%s.mat',subid,pipeline_dg_erp.sname));
    load(fname);
    
    % for the EFR data there were two types of triggers. 224 correspond to
    % gamma stimuli (i.e. sustained AM tones in 2-s long windows) and 192
    % corresponds to delta-gamma stimuli (i.e. on/off AM stimuli that each
    % are 0.25 s long). 
    tid_gamma       = find(dat.trialinfo==224);
    tid_delta_gamma = find(dat.trialinfo==192);
    
    % once we have the entries that correspond to each condition we prepare
    % 3d arrays for each condition and average over the third dimension
    erp_subid_gamma         = mean(cat(3,dat.trial{tid_gamma}),3)';
    erp_subid_delta_gamma   = mean(cat(3,dat.trial{tid_delta_gamma}),3)';
    
    % define a corresponding time vector and ensure that each vector in the
    % cell dat.time are identical
    time = dat.time{1};
    if any(sum(ismember(cat(1,dat.time{:})',unique(time)))~=numel(unique(time)))
        error('something is wrong!')
    end
    
    % finally, we extract the mean N1 amplitude for both stimulus
    % conditions
    n1amp_dg(subid,1) = mean(mean(erp_subid_delta_gamma(time>=0.075 & time<= 0.130,roi)));
    n1amp_g(subid,1)  = mean(mean(erp_subid_gamma(time>=0.075 & time<= 0.130,roi)));
end

% export <dtab> table
dtab = table(participants_tsv.participant_id,participants_tsv.hearing_status,n1amp_dg,n1amp_g);
dtab.Properties.VariableNames = {'participant_id','hearing_status','delta_gamma_n1','gamma_n1'};

end