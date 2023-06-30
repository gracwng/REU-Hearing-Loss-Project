%> @file  evaluate_encoding_analysis.m
%> @brief Encoding analysis for attended and unattended
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



function evaluate_encoding_analysis(subid,pipeline_aud_attention,pipeline_eeg_attention,sdir,cameq)

rng('default'); parcreaterandstream(44, randi(10000)+subid)


srdat = sr_importdata(subid,pipeline_aud_attention,...
    pipeline_eeg_attention,sdir,cameq);


   
    
opts_forward = struct;
opts_forward.kinner = 5;
opts_forward.kouter = 10;
opts_forward.lambda = logspace(log10(10^(-3)),log10(10^6),50);
opts_forward.znormd = 1; 
opts_forward.storew = 0; 
opts_forward.gof = 'estcorr';
opts_forward.phaserand.roi = [4 5 6 9 10 11 39 40 41 44 45 46  38 47];
opts_forward.phaserand.nperm = 1000;
opts_forward.flagoi = 0:32;


xx  = matlag3d(srdat.aud_feature.target_st,     opts_forward.flagoi);
yy  = srdat.eeg_feature.eeg_st;


[vlog_st] = regevalnestedloopssvdridge(opts_forward,xx,yy);


xx  = matlag3d(srdat.aud_feature.target_tt,     opts_forward.flagoi);
yy  = srdat.eeg_feature.eeg_tt;


[vlog_att] = regevalnestedloopssvdridge(opts_forward,xx,yy);
   


xx  = matlag3d(srdat.aud_feature.masker_tt,      opts_forward.flagoi);
yy  = srdat.eeg_feature.eeg_tt;


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


save(fullfile(sdir,'results',sprintf('sub-%0.3i_encoding_%s-%s-%s.mat',subid,pipeline_aud_attention.sname,pipeline_eeg_attention.sname,cameq)),'dataout')

end