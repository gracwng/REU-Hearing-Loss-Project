
bidsdir = 'C:\Users\student\Downloads\ds-eeg-snhl 2\ds-eeg-snhl';
sdir = 'C:\Users\student\Documents\snhl-master\results';
% 
% for sub = 1:44
%     runall(sub, bidsdir, sdir);
% end
% load('C:\Users\student\Documents\snhl-master\results\features\eeg\sub-002_eeg-wf_erp.mat')

export_summaries(sdir, bidsdir);