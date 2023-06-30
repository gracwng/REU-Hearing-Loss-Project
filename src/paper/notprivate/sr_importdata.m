%> @file  sr_importdata.m
%> @brief Imports preprocessed EEG and audio features from a given subject from the selective attention experiment and prepares a struct used for stimulus-response analysis 
%> @param subid subject id (an integer between 1 and 44)
%> @param pipeline_aud the preprocessing pipeline struct for the audio (see workflows_paper.m)
%> @param pipeline_eeg the preprocessing pipeline struct for the eeg (see workflows_paper.m)
%> @param sdir where was the derived features stored?
%> @param cameq ['wa'/'woa'/'woacontrol']: please see readme
%>
%> Please keep in mind that we assume that the EEG preprocessing and audio preprocessing pipelines already have segmented EEG and audio data such that the segments are temporally consistent. This function does not check for this and should thus be used with caution.


function srdat = sr_importdata(subid,pipeline_aud,pipeline_eeg,sdir,cameq)


load(fullfile(sdir,'features','aud',sprintf('sub-%0.3i_aud-%s-%s.mat',subid,pipeline_aud.sname,cameq)))
load(fullfile(sdir,'features','eeg',sprintf('sub-%0.3i_eeg-%s.mat',subid,pipeline_eeg.sname)))


id_st = ismember(cat(1,feat.single_talker_two_talker{:}),'singletalker');
id_tt = ismember(cat(1,feat.single_talker_two_talker{:}),'twotalker');

srdat = struct;
srdat.aud_feature.target_st = cat(3,feat.target{id_st});
srdat.aud_feature.target_tt = cat(3,feat.target{id_tt});
srdat.aud_feature.masker_tt = cat(3,feat.masker{id_tt});
srdat.eeg_feature.eeg_st = permute(cat(3,dat.trial{id_st}),[2 1 3]);
srdat.eeg_feature.eeg_tt = permute(cat(3,dat.trial{id_tt}),[2 1 3]);

end

