%> @file  runall_sr_control.m
%> @brief Performs the same analysis as "runall.m" but considers yet
%> another way of defining audio "without CamEQ" for HI listeners. In this
%> case the audio is extracted in the exact same way for NH and HI
%> listeners rather than inverse filtering the already CamEQ equalized
%> files.
%> @param subid subject id (an integer between 1 and 44)
%> @param bidsdir the root of the BIDs directory
%> @param sdir directory in which the features and model results are stored
%> @param eegpreproc a flag (0/1) that indicates whether or not to build
%> eeg features. by default, it is assumed that "runall" has already been
%> called and that there thus is no need to build these features again
%> @param audpreproc a flag (0/1) that indicates whether or not to build
%> audio features. this can by handy with limited signal processing licenses

function runall_sr_control(subid,bidsdir,sdir,eegpreproc,audpreproc)

if nargin < 4 || isempty(eegpreproc); eegpreproc = 0; end
if nargin < 5 || isempty(audpreproc); audpreproc = 0; end

global showcomments
showcomments = 0;

initdir
workflows_paper

cd(fullfile(fileparts(which('initdir.m')),'src','paper','private'))


rng('default'); parcreaterandstream(44, randi(10000)+subid)

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Turn raw data into features
if audpreproc
build_aud_features(subid,pipeline_aud_attention,               bidsdir,sdir,'woacontrol')
build_aud_features(subid,pipeline_aud_attention_multiple_c,    bidsdir,sdir,'woacontrol')
end

if eegpreproc
build_eeg_features(subid,pipeline_eeg_attention,               bidsdir,sdir)
build_eeg_features(subid,pipeline_eeg_attention_st_denoising,  bidsdir,sdir)
end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Train and evaluate stimulus-response models on the features. The data
% will be stored in: <_sdir/results>. Note that we perform a number of
% control conditions for this analysis


paud = pipeline_aud_attention;
peeg = pipeline_eeg_attention_st_denoising;
evaluate_classification_analysis(subid, paud,peeg,sdir,'woacontrol')

paud = pipeline_aud_attention;
peeg = pipeline_eeg_attention;
evaluate_encoding_analysis(subid,       paud,peeg,sdir,'woacontrol')


paud = pipeline_aud_attention_multiple_c;
peeg = pipeline_eeg_attention;
evaluate_encoding_analysis(subid,       paud,peeg,sdir,'woacontrol')


paud = pipeline_aud_attention;
peeg = pipeline_eeg_attention;
evaluate_reconstruction_analysis(subid, paud,peeg,sdir,'woacontrol')


end

