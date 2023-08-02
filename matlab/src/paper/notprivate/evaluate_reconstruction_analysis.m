%> @file  evaluate_reconstruction_analysis.m
%> @brief Stimulus reconstruction analysis for attended and unattended
%> speech in single-talker and two-talker conditions. This analysis is
%> performed using nested cross-validation procedures. The parameters are
%> here pre-specified for the manuscript.
%> @param subid subject id (an integer between 1 and 44)
%> @param pipeline_aud the preprocessing pipeline struct for the audio (see workflows_paper.m)
%> @param pipeline_eeg the preprocessing pipeline struct for the eeg (see workflows_paper.m)
%> @param sdir where was the derived features stored and where will the results be stored?
%> @param cameq ['wa'/'woa'] (with/without CamEQ). woa = focus on audio
%> without Cambridge equalization, wa = focus on audio with Cambridge
%> amplification (default)

%> 2019/07/16 major: updated woa input to match build_aud_features




function evaluate_reconstruction_analysis(subid,pipeline_aud_attention,pipeline_eeg_attention,sdir,cameq)

rng('default'); parcreaterandstream(44, randi(10000)+subid)


srdat = sr_importdata(subid,pipeline_aud_attention,...
    pipeline_eeg_attention,sdir,cameq);


   
    
opts_backward = struct;
opts_backward.kinner = 5;
opts_backward.kouter = 10;
opts_backward.lambda = logspace(log10(10^(-3)),log10(10^6),50);
opts_backward.znormd = 1; 
opts_backward.storew = 0; 
opts_backward.gof = 'estcorr';
opts_backward.phaserand.roi = 1;
opts_backward.phaserand.nperm = 1000;
opts_backward.blagoi = -32:0;


xx  = matlag3d(srdat.eeg_feature.eeg_st,    opts_backward.blagoi);
yy  = srdat.aud_feature.target_st;


[vlog_st] = regevalnestedloopssvdridge(opts_backward,xx,yy);


xx  = matlag3d(srdat.eeg_feature.eeg_tt,    opts_backward.blagoi);
yy  = srdat.aud_feature.target_tt;




[vlog_att] = regevalnestedloopssvdridge(opts_backward,xx,yy);
   

xx  = matlag3d(srdat.eeg_feature.eeg_tt,    opts_backward.blagoi);
yy  = srdat.aud_feature.masker_tt;



[vlog_itt] = regevalnestedloopssvdridge(opts_backward,xx,yy);
       


dataout = struct;
dataout.reconstruction_results = struct;
dataout.reconstruction_results.vlog_st = vlog_st;
dataout.reconstruction_results.vlog_itt = vlog_itt;
dataout.reconstruction_results.vlog_att = vlog_att;
dataout.reconstruction_results.opts_backward = opts_backward;
dataout.reconstruction_results.subid = subid;
dataout.reconstruction_results.pipeline_aud_attention = pipeline_aud_attention;
dataout.reconstruction_results.pipeline_eeg_attention = pipeline_eeg_attention;
dataout.reconstruction_results.woa = cameq;
    
try
    gloal hash_cmd
    dataout.reconstruction_results.hash_cmd = hash_cmd;
end

if ~exist(fullfile(sdir,'results'))
    mkdir(fullfile(sdir,'results'))
end


save(fullfile(sdir,'results',sprintf('sub-%0.3i_reconstruction_%s-%s-%s.mat',subid,pipeline_aud_attention.sname,pipeline_eeg_attention.sname,cameq)),'dataout')


end