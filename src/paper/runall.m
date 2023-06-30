%> @file  runall.m
%> @brief Function used for preprocessing data, performing
%> stimulus-response analysis and exporting results (as described in the
%> manuscript)
%> @param subid subject id (an integer between 1 and 44)
%> @param bidsdir the root of the BIDs directory
%> @param sdir directory in which the features and model results are stored

function runall(subid,bidsdir,sdir)

if unix(['git diff-index --quiet HEAD'])==1; warning('The repository may be dirty. Please commit before executing'); end

global showcomments
showcomments = 0;

initdir
workflows_paper

rng('default');
parcreaterandstream(subid, randi(10000)+subid)

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Turn raw data into features

% build_aud_features(subid,pipeline_aud_attention,               bidsdir,sdir,'wa')
% build_aud_features(subid,pipeline_aud_attention_multiple_c,    bidsdir,sdir,'wa')
% 
% build_aud_features(subid,pipeline_aud_attention,               bidsdir,sdir,'woa')
% build_aud_features(subid,pipeline_aud_attention_multiple_c,    bidsdir,sdir,'woa')
% 
% build_eeg_features(subid,pipeline_eeg_attention,               bidsdir,sdir)
% build_eeg_features(subid,pipeline_eeg_attention_st_denoising,  bidsdir,sdir)

build_eeg_features(subid,pipeline_erp,                         bidsdir,sdir)
% build_eeg_features(subid,pipeline_dg_erp,                      bidsdir,sdir)

% build_eeg_features(subid,pipeline_dg_itpc,                     bidsdir,sdir)

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Train and evaluate stimulus-response models on the features. The data
% will be stored in: <_sdir/results>. Note that we perform a number of
% % control conditions for this analysis
% 
% 
% paud = pipeline_aud_attention;
% peeg = pipeline_eeg_attention_st_denoising;
% evaluate_classification_analysis(subid, paud,peeg,sdir,'wa')
% evaluate_classification_analysis(subid, paud,peeg,sdir,'woa')
% 
% paud = pipeline_aud_attention;
% peeg = pipeline_eeg_attention;
% evaluate_encoding_analysis(subid,       paud,peeg,sdir,'wa')
% evaluate_encoding_analysis(subid,       paud,peeg,sdir,'woa')
% 
% 
% paud = pipeline_aud_attention_multiple_c;
% peeg = pipeline_eeg_attention;
% evaluate_encoding_analysis(subid,       paud,peeg,sdir,'wa')
% evaluate_encoding_analysis(subid,       paud,peeg,sdir,'woa')
% 
% 
% paud = pipeline_aud_attention;
% peeg = pipeline_eeg_attention;
% evaluate_reconstruction_analysis(subid, paud,peeg,sdir,'wa')
% evaluate_reconstruction_analysis(subid, paud,peeg,sdir,'woa')
% 
% 
% % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% % Export ITPC data
% 
% evaluate_itpc(subid,pipeline_dg_itpc,sdir)


