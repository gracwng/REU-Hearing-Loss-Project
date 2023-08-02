function runall_sr_train_on_st(subid,bidsdir,sdir,eegpreproc,audpreproc,cameq)

if nargin < 4 || isempty(eegpreproc); eegpreproc = 0; end
if nargin < 5 || isempty(audpreproc); audpreproc = 0; end
if nargin < 6 || isempty(cameq);      cameq = 'woa'; end

global showcomments
showcomments = 0;

initdir
workflows_paper

paud = pipeline_aud_attention;
peeg = pipeline_eeg_attention_st_denoising;


cd(fullfile(fileparts(which('initdir.m')),'src','paper','private'))


rng('default'); parcreaterandstream(44, randi(10000)+subid)

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Turn raw data into features
if audpreproc
build_aud_features(subid,paud,bidsdir,sdir,cameq)
end

if eegpreproc
build_eeg_features(subid,peeg,bidsdir,sdir)
end


srdat = sr_importdata(subid,paud,peeg,sdir,cameq);



fprintf('\n ========================================================================')
fprintf('\n Processing data from subject sub-%0.3i',subid)
fprintf('\n Fitting encoding models')
preproc_greetings(subid,pipeline_eeg_attention_st_denoising,bidsdir,sdir)
preproc_greetings(subid,pipeline_aud_attention,bidsdir,sdir)



opts_f = struct;
opts_f.znormd = 1;
opts_f.lagoi = 0 : 32;
opts_f.forward = 1;
opts_f.lfun = 'estcorr';
opts_f.np = 1000;
opts_f.lambda = logspace(log10(10^(-3)),log10(10^6),50);
vlog_f = evaluate_regressionaccuracies_train_on_st(srdat,opts_f);

fprintf('\n Fitting decoding models')


opts_b = struct;
opts_b.znormd = 1;
opts_b.lagoi = -32:0;
opts_b.forward = 0;
opts_b.lfun = 'estcorr';
opts_b.np = 1000;
opts_b.lambda = logspace(log10(10^(-3)),log10(10^6),50);
vlog_b = evaluate_regressionaccuracies_train_on_st(srdat,opts_b);

dataout = struct;
dataout.vlog_b = vlog_b;
dataout.vlog_f = vlog_f;
dataout.cameq = cameq;
dataout.opts_f = opts_f;
dataout.opts_b = opts_b;
dataout.paud = paud;
dataout.peeg = peeg;

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% in addition to the above analysis we inspect the stimulus 
% reconstruction weights. the goal is NOT to make inference 
% on brain processes but instead to better understand how
% the decoder map from EEG response to actual data. as in 
% a number of studies we here fix the regularization parameter
%
% 
% these results should be taken with a grain of salt for various
% reasons (e.g. filtering, interpretability of decoding weights 
% etc etc)

lambda_fixed = opts_b.lambda(40);

% first we fit models trained on attended speech in two-talker 
% condition
xx = matsqueeze3d2d(srdat.eeg_feature.eeg_tt);
yy = matsqueeze3d2d(srdat.aud_feature.target_tt);

[~,wwatt] = regfitsvdridge(matlag(xx,opts_b.lagoi),yy,[],[],lambda_fixed,opts_b.znormd,'estcorr');


% then we fit models trained on unattended speech in two-talker 
% condition
xx = matsqueeze3d2d(srdat.eeg_feature.eeg_tt);
yy = matsqueeze3d2d(srdat.aud_feature.masker_tt);

[~,wwitt] = regfitsvdridge(matlag(xx,opts_b.lagoi),yy,[],[],lambda_fixed,opts_b.znormd,'estcorr');


% finally, on models trained on single-talker speech
xx = matsqueeze3d2d(srdat.eeg_feature.eeg_st);
yy = matsqueeze3d2d(srdat.aud_feature.target_st);

[~,wwst] = regfitsvdridge(matlag(xx,opts_b.lagoi),yy,[],[],lambda_fixed,opts_b.znormd,'estcorr');


dataout.weights = struct;
dataout.weights.wwst = wwst;
dataout.weights.wwitt = wwitt;
dataout.weights.wwatt = wwatt;
dataout.weights.lagoi = opts_b.lagoi;
dataout.weights.lambda = lambda_fixed;




if ~exist(fullfile(sdir,'results'))
    mkdir(fullfile(sdir,'results'))
end


save(fullfile(sdir,'results',sprintf('sub-%0.3i_regressionacc_train_on_st_%s-%s-%s.mat',subid,paud.sname,peeg.sname,cameq)),'dataout')



end












function vlog = evaluate_regressionaccuracies_train_on_st(srdat,opts)

% ===================
% Single talker data:
%
ast = srdat.aud_feature.target_st;
est = srdat.eeg_feature.eeg_st;

% ===================
% Two talker data
%
att = srdat.aud_feature.target_tt;
ett = srdat.eeg_feature.eeg_tt;
dtt = srdat.aud_feature.masker_tt;



if opts.forward==1
    fprintf('\n Fitting encoding models')
    
    % Since it is a forward model, we now lag the envelope representation
    ast  = matlag3d(ast,opts.lagoi);
    att  = matlag3d(att,opts.lagoi);
    dtt  = matlag3d(dtt,opts.lagoi);
else
    
    fprintf('\n Fitting stimulus-reconstruction models')
    
    % Since it is a backward model, we now lag the EEG data
    est  = matlag3d(est,opts.lagoi);
    ett  = matlag3d(ett,opts.lagoi);
end


if opts.znormd
    
    
    % Here we z-score to the empirical mean and standard deviation of the
    % single-talker data. We do this both for the EEG data and envelope
    % representations
    mua     = mean(matsqueeze3d2d(ast));
    stda    = std(matsqueeze3d2d(ast));
    mue     = mean(matsqueeze3d2d(est));
    stde    = std(matsqueeze3d2d(est));
    
    % Apply the z-transformations to data from each trial 
    % Note that "regevalloosvdridge" rely on the routine, "regfitsvdridge"
    % which means that it handles z-scoring (in this case for the
    % single-talker data)
    for t = 1 : size(att,3)
        att(:,:,t) = matznorm(att(:,:,t),mua,stda);
        dtt(:,:,t) = matznorm(dtt(:,:,t),mua,stda);
        ett(:,:,t) = matznorm(ett(:,:,t),mue,stde);
    end
end



% Fit the models based on single-talker data 
opts.storew = 1;

if opts.forward==1
    
    % If we're focusing on an encoding model, then we map from envelope
    % representation to EEG response
    ww = regevalloosvdridge(opts,ast,est);
else
    % If we're focusing on a decoding model, then we map from EEG to
    % envelope
    ww = regevalloosvdridge(opts,est,ast);
end


lfun = str2func(opts.lfun);
roi = [4 5 6 9 10 11 39 40 41 44 45 46 38 47];
if opts.forward==1
    pacc =[];
    for t = 1 : size(att,3)
        pacc(t,:,1) = lfun(att(:,:,t)*ww,ett(:,:,t));
        pacc(t,:,2) = lfun(dtt(:,:,t)*ww,ett(:,:,t));
        
        
        if opts.np>0
            [sur_acc_att,sur_roi_att] = regevalsurrdata(att(:,:,t),ett(:,:,t),ww,opts.np,opts.lfun,roi);
            [sur_acc_dtt,sur_roi_dtt] = regevalsurrdata(dtt(:,:,t),ett(:,:,t),ww,opts.np,opts.lfun,roi);
            
            surr_dat{t} = struct;
            surr_dat{t}.sur_acc_att = sur_acc_att;
            surr_dat{t}.sur_acc_dtt = sur_acc_dtt;
            surr_dat{t}.sur_roi_att = sur_roi_att;
            surr_dat{t}.sur_roi_dtt = sur_roi_dtt;
        else
            surr_dat = struct;
        end
        
    end
    
else
    pacc =[];
    for t = 1 : size(att,3)
        pacc(t,:,1) = lfun(ett(:,:,t)*ww,att(:,:,t));
        pacc(t,:,2) = lfun(ett(:,:,t)*ww,dtt(:,:,t));
        
        
        
        if opts.np>0
            [sur_acc_att,sur_roi_att] = regevalsurrdata(ett(:,:,t),att(:,:,t),ww,opts.np,opts.lfun,1);
            [sur_acc_dtt,sur_roi_dtt] = regevalsurrdata(ett(:,:,t),dtt(:,:,t),ww,opts.np,opts.lfun,1);
            
            surr_dat{t} = struct;
            surr_dat{t}.sur_acc_att = sur_acc_att;
            surr_dat{t}.sur_acc_dtt = sur_acc_dtt;
            surr_dat{t}.sur_roi_att = sur_roi_att;
            surr_dat{t}.sur_roi_dtt = sur_roi_dtt;
        else
            surr_dat = struct;
        end
    end
end

vlog = struct;
vlog.pacc = pacc;
vlog.opts = opts;
vlog.ww = ww;
vlog.surr_dat = surr_dat;

end


