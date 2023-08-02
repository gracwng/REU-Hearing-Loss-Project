
bidsdir = 'C:\Users\student\Downloads\ds-eeg-snhl 2\ds-eeg-snhl';
sdir = 'C:\Users\student\Documents\snhl-master\results';
% 
% for sub = 1:44
%     runall(sub, bidsdir, sdir);
% end

export_summaries(sdir, bidsdir);