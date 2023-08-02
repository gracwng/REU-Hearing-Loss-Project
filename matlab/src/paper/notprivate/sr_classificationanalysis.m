%> @file  sr_classificationanalysis.m
%> @brief Trains a reconstruction model on single-talker data using LOO and
%> evaluates how accurately the model can be used to discrinate between
%> attended and unattended speech from two-talker data.
%> @param opts configuration structure
%> @param opts.tdur duration of decoding segments (in s)
%> @param opts.fs sampling rate of preprocessed data (e.g. fs=64)
%> @param opts.tshift how long are the shifts (in s) between each segment? the decoding segments are nonoverlapping and shifted with opts_classification.tdur + opts_classification.tshift)
%> @param opts.lagoi lags of interest (e.g. -32:0)
%> @param opts.znormd flag indicating if the data should be z-scored (1) or not (0)
%> @param opts.lambda regularization parameters of interest (e.g [1 10 100])
%> @param opts.gof goodness of fit metric (e.g. 'estcorr')
%> @param srdat imported and preprocessed audio/EEG data (see sr_importdata.m)
%>
%> 
%> The backward models in this project are based on ridge-regularized filters 
%> (and not tikhonov filters as they potentially introduce relatively strong cross-channel leakages)
%>
%> to do:
%> right now the opt.gof functionality is not included and this function only relies on 'estcorr'. this could be nice to include 
%>
%> history
%> 2019/07/12 allowed the classification decision to handle multidimensional aud features 
 
function vlog = sr_classificationanalysis(opts,srdat)

if nargin < 1 || isempty(opts); opts = struct; end
if isfield(opts,'tdur')==0; opts.tdur = 9.5; end
if isfield(opts,'tshift')==0; opts.tshift = 5; end
if isfield(opts,'fs')==0; opts.fs = 64; end
if isfield(opts,'lagoi')==0; opts.lagoi = -32:0; end
if isfield(opts,'znormd')==0; opts.znormd = 1; end
if isfield(opts,'lambda')==0; opts.lambda = logspace(-3,6,50); end
if isfield(opts,'gof')==0; opts.gof = 'estcorr'; end


eeg_lag_st      = matlag3d(srdat.eeg_feature.eeg_st,opts.lagoi);
aud_target_st   = srdat.aud_feature.target_st;
opts.storew     = 1;
ww              = regevalloosvdridge(opts,eeg_lag_st,aud_target_st);



eeg_st          = matsqueeze3d2d(srdat.eeg_feature.eeg_st);
eeg_tt          = matsqueeze3d2d(srdat.eeg_feature.eeg_tt);

aud_target_st   = matsqueeze3d2d(srdat.aud_feature.target_st);
aud_target_tt   = matsqueeze3d2d(srdat.aud_feature.target_tt);
aud_masker_tt   = matsqueeze3d2d(srdat.aud_feature.masker_tt);



if opts.znormd
    [~,eeg_tt]          = matznormxt(matlag(eeg_st,opts.lagoi),matlag(eeg_tt,opts.lagoi));
    [~,aud_target_tt]   = matznormxt(aud_target_st,aud_target_tt);
    [~,aud_masker_tt]   = matznormxt(aud_target_st,aud_masker_tt);
else
    eeg_tt = matlag(eeg_tt,opts.lagoi);
end



for td = 1 : length(opts.tdur)
    
    cval    = [];
    win     = 1 : opts.tdur(td)*opts.fs;
    win_log = [win(1) win(end)];
    
    while win(end)+length(opts.lagoi) < size(eeg_tt,1)
        pred = eeg_tt(win(1):win(end),:)*ww;
        
        cval_segment = [estcorr(aud_target_tt(win,:),pred) estcorr(aud_masker_tt(win,:),pred)];
        cval = cat(1,cval,cval_segment);
        
        win = win + opts.tdur(td)*opts.fs + opts.tshift*opts.fs;
        win_log = [win_log; [win(1) win(end)]];
    end
    
    
    vlog{td} = struct;
    vlog{td}.cacc = mean(cval(:,1:size(pred,2))>cval(:,(size(pred,2)+1):end));
    vlog{td}.cval = cval;
    vlog{td}.opts = opts;
    vlog{td}.win_log = win_log;
    
end

end