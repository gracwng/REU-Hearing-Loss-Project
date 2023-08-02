%> @file  runall_binauralhf_FCz.m
%> @brief Performs an encoding analysis operating on multidimensional
%> cochleograms extracted for each of the two audio channels. For
%> computational purposes we only focus on EEG data in channel FCz
%> @param subid subject id (an integer between 1 and 44)
%> @param bidsdir the root of the BIDs directory
%> @param sdir directory in which the features and model results are stored
%> @param eegpreproc a flag (0/1) that indicates whether or not to build
%> eeg features. 1 = assumes that these features have already been
%> extracted
%> @param audpreproc a flag (0/1) that indicates whether or not to build
%> audio features. this can by handy with limited signal processing licenses
%> @param fitmodels a flag (0/1) that indicates whether or not to actually
%> fit and evaluate the encoding models


function runall_binauralhf_FCz(subid,bidsdir,sdir,eegpreproc,audpreproc,fitmodels)

if nargin < 4 || isempty(eegpreproc); eegpreproc = 0; end
if nargin < 5 || isempty(audpreproc); audpreproc = 0; end
if nargin < 6 || isempty(fitmodels);  fitmodels = 1; end

global showcomments
showcomments = 0;

initdir
workflows_paper

cd(fullfile(fileparts(which('initdir.m')),'src','paper','private'))


pipeline_aud_binaural_highfreq = struct;
pipeline_aud_binaural_highfreq.task = 'selectiveattention';
pipeline_aud_binaural_highfreq.sname = 'wf_aud_att_binaural_hf'; 
pipeline_aud_binaural_highfreq.pp = ...
                                {'pp_aud_gammatone_highfreq',... 
                                 'pp_aud_fullwave_rectify',...
                                 'pp_aud_powerlaw03',...
                                 'pp_aud_lowpass6000_44100',... 
                                 'pp_aud_resample12000_44100',... 
                                 'pp_aud_lowpass256_12000',...
                                 'pp_aud_resample512_12000',...
                                 'pp_aud_lowpass30_512',...
                                 'pp_aud_resample64_512',...
                                 'pp_aud_highpass1_64',...
                                 'pp_aud_lowpass9_64',...
                                 'pp_aud_toi_attention'};
                 
                 
                 
rng('default'); parcreaterandstream(44, randi(10000)+subid)

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Turn raw data into features
if audpreproc
build_aud_features(subid,pipeline_aud_binaural_highfreq,bidsdir,sdir,'wa')
build_aud_features(subid,pipeline_aud_binaural_highfreq,bidsdir,sdir,'woa')
build_aud_features(subid,pipeline_aud_binaural_highfreq,bidsdir,sdir,'woacontrol')
end

if eegpreproc
% Note that we only focus on encoding models, so it is not necessary to
% denoise with spatial denoising filters trained only on single-talker data
build_eeg_features(subid,pipeline_eeg_attention,               bidsdir,sdir)
end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Train and evaluate stimulus-response models on the features. The data
% will be stored in: <_sdir/results>. Note that we perform a number of
% control conditions for this analysis


if fitmodels
paud = pipeline_aud_binaural_highfreq;
peeg = pipeline_eeg_attention;
evaluate_encoding_analysis_roi(subid,       paud,peeg,sdir,'wa')


paud = pipeline_aud_binaural_highfreq;
peeg = pipeline_eeg_attention;
evaluate_encoding_analysis_roi(subid,       paud,peeg,sdir,'woa')


paud = pipeline_aud_binaural_highfreq;
peeg = pipeline_eeg_attention;
evaluate_encoding_analysis_roi(subid,       paud,peeg,sdir,'woacontrol')
end

end






function evaluate_encoding_analysis_roi(subid,pipeline_aud_attention,pipeline_eeg_attention,sdir,cameq)

rng('default'); parcreaterandstream(44, randi(10000)+subid)


srdat = sr_importdata(subid,pipeline_aud_attention,...
    pipeline_eeg_attention,sdir,cameq);



fprintf('\n Evaluating encoding models for sub-%0.3i',subid)
fprintf('\n Auditory pipeline is: %s',pipeline_aud_attention.sname)
fprintf('\n EEG pipeline is: %s',pipeline_eeg_attention.sname)
fprintf('\n Data will be stored as: %s',fullfile(sdir,'results',sprintf('sub-%0.3i_encoding_FCz_%s-%s-%s.mat',subid,pipeline_aud_attention.sname,pipeline_eeg_attention.sname,cameq)))
fprintf('\n \n \n Auditory pipeline is: \n ')
fprintf(1, '       %s \n', pipeline_aud_attention.pp{:})
fprintf('\n \n \n EEG pipeline is: \n')
fprintf(1, '       %s \n', pipeline_eeg_attention.pp{:})
fprintf('\n \n \n Aud dimensionality is: [%i x %i ] \n ',size(srdat.aud_feature.target_st,1),size(srdat.aud_feature.target_st,2))
fprintf('EEG dimensionality is: [%i x %i ] \n ',size(srdat.eeg_feature.eeg_st,1),1)


roi = 47;


opts_forward = struct;
opts_forward.kinner = 5;
opts_forward.kouter = 10;
opts_forward.lambda = logspace(log10(10^(-3)),log10(10^6),50);
opts_forward.znormd = 1; 
opts_forward.storew = 0; 
opts_forward.gof = 'estcorr';
opts_forward.phaserand.roi = roi;
opts_forward.phaserand.nperm = 1000;
opts_forward.flagoi = 0:32;


xx  = matlag3d(srdat.aud_feature.target_st,     opts_forward.flagoi);
yy  = srdat.eeg_feature.eeg_st;
yy  = yy(:,roi,:);

[vlog_st] = regevalnestedloopssvdridge(opts_forward,xx,yy);


xx  = matlag3d(srdat.aud_feature.target_tt,     opts_forward.flagoi);
yy  = srdat.eeg_feature.eeg_tt;
yy  = yy(:,roi,:);

[vlog_att] = regevalnestedloopssvdridge(opts_forward,xx,yy);
   


xx  = matlag3d(srdat.aud_feature.masker_tt,      opts_forward.flagoi);
yy  = srdat.eeg_feature.eeg_tt;
yy  = yy(:,roi,:);


[vlog_itt] = regevalnestedloopssvdridge(opts_forward,xx,yy);
       


dataout = struct;
dataout.encoding_results = struct;
dataout.encoding_results.vlog_st = vlog_st;
dataout.encoding_results.vlog_itt = vlog_itt;
dataout.encoding_results.vlog_att = vlog_att;
dataout.encoding_results.opts_forward = opts_forward;
dataout.encoding_results.subid = subid;
dataout.encoding_results.pipeline_aud_attention = pipeline_aud_attention;
dataout.encoding_results.pipeline_eeg_attention = pipeline_eeg_attention;
dataout.encoding_results.woa = cameq;

try
    gloal hash_cmd
    dataout.encoding_results.hash_cmd = hash_cmd;
end    
    
if ~exist(fullfile(sdir,'results'))
    mkdir(fullfile(sdir,'results'))
end


save(fullfile(sdir,'results',sprintf('sub-%0.3i_encoding_FCz_%s-%s-%s.mat',subid,pipeline_aud_attention.sname,pipeline_eeg_attention.sname,cameq)),'dataout')

end
