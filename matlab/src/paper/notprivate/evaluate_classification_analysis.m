%> @file  evaluate_classification_analysis.m
%> @brief Performs and evaluates the attention classifcation analysis using
%> models trained on single-talker data (with a leave-one-out
%> cross-validation procedure)
%> @param subid subject id (an integer between 1 and 44)
%> @param pipeline_aud the preprocessing pipeline struct for the audio (see workflows_paper.m)
%> @param pipeline_eeg the preprocessing pipeline struct for the eeg (see workflows_paper.m)
%> @param sdir where was the derived features stored and where will the results be stored?
%> @param cameq ['wa'/'woa'] (with/without CamEQ). woa = focus on audio
%> without Cambridge equalization, wa = focus on audio with Cambridge
%> amplification (default)

%> 2019/07/16 major: updated woa input to match build_aud_features

function evaluate_classification_analysis(subid,pipeline_aud_attention,pipeline_eeg_attention,sdir,cameq)

rng('default'); parcreaterandstream(44, randi(10000)+subid)


srdat = sr_importdata(subid,pipeline_aud_attention,...
    pipeline_eeg_attention,sdir,cameq);


opts_classification = struct;
opts_classification.lambda = logspace(log10(10^(-3)),log10(10^6),50);
opts_classification.fs = 64;
opts_classification.tdur = [1 3 5 7 10 15 20 30]-0.5;
opts_classification.tshift = 5;
opts_classification.lagoi = -32:0;
opts_classification.znormd = 1;
opts_classification.gof = 'estcorr';
vlog = sr_classificationanalysis(opts_classification,srdat);

dataout = struct;
dataout.classification_results = struct;
dataout.classification_results.vlog = vlog;
dataout.classification_results.opts_classification = opts_classification;
dataout.classification_results.woa = cameq;
dataout.classification_results.subid = subid;
dataout.classification_results.pipeline_aud_attention = pipeline_aud_attention;
dataout.classification_results.pipeline_eeg_attention = pipeline_eeg_attention;

try
    gloal hash_cmd
    dataout.classification_results.hash_cmd = hash_cmd;
end

if ~exist(fullfile(sdir,'results'))
    mkdir(fullfile(sdir,'results'))
end

save(fullfile(sdir,'results',sprintf('sub-%0.3i_classification_%s-%s-%s.mat',subid,pipeline_aud_attention.sname,pipeline_eeg_attention.sname,cameq)),'dataout')

end