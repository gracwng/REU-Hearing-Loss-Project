%> @file  preproc_eogdenoise.m
%> @brief Regress out EOG artifacts from EEG data (stored in Fieldtrip format)
%> @param opts configuration structure
%> @param opts.demean a 0/1 flag, 1 = center the data prior to spatial filtering (default), 0 = leave as is
%> @param opts.zthresh what threshold do we set for the eog artefact detection? default = 4
%> @param opts.eogchan which eog channels do we here consider? e.g. {'EOG'}
%> @param opts.pthresh set a power ratio threshold that defines how many eigenvectors to retain
%> @param opts.artseg  this is handy if you want to manually label EOG artifacts (which is fairly straightforward). when this field is not empty, Fieldtrip will not be used for EOG labelling
%> @param dat a Fieldtrip data structure
%> @retval out a structure with relevant fields for denoising (filters and z-scoring parameters)
%> @retval dat denoised eeg data (in Fieldtrip format)

%> history:
%> 2019/07/05 major: added comments and renamed function. 
%> 2019/07/12 major: updated demean field to allow for demean = 0 
%>
%> When using this function please cite:
%>
%> Wong, Daniel DE, et al. "A comparison of regularization methods in
%> forward and backward models for auditory attention decoding."
%> Frontiers in neuroscience 12 (2018): 531.
%>
%> de Cheveigné A, Parra LC (2014). "Joint decorrelation, a versatile tool 
%> for multichannel data analysis. Neuroimage 98:487?505.
%> Available at: http://dx.doi.org/10.1016/j.neuroimage.2014.05.068.


function [out,dat] = preproc_eogdenoise(opts,dat)

if nargin < 1 || isempty(opts);     opts = struct; end
if isfield(opts,'demean')==0;       opts.demean = 1; end
if isfield(opts,'zthresh')==0;      opts.zthresh = 4; end
if isfield(opts,'eogchan')==0;      opts.eogchan = {'EOG_com','Fp1','Fpz','Fp2'}; end
if isfield(opts,'pthresh')==0;      opts.pthresh = 0.8; end
if isfield(opts,'artseg')==0;       opts.artseg = []; end

if nargin < 2 || isempty(dat);      warning('input data not supplied'); end


% concatenate data from a all trials into one array
datx = cat(2,dat.trial{:})';

% store the mean across all trials
mu = mean(datx);

if opts.demean
% center the data
for tt = 1 : numel(dat.trial)
    dat.trial{tt} = bsxfun(@minus,dat.trial{tt}',mu)';
end


% center the 2d array as well (this is redundant, but will be used later)
datx = bsxfun(@minus,datx,mu);
end



if isempty(opts.artseg)
    
    % detect the eog artefacts using a very simple procedure (here using
    % Fieldtrip for convenience and transparency). we simply take Fieldtrip's
    % default recommendations
    cfg                              = [];
    cfg.artfctdef.zvalue.channel     = opts.eogchan;
    cfg.artfctdef.zvalue.cutoff      = opts.zthresh;
    cfg.artfctdef.zvalue.trlpadding  = 0;
    cfg.artfctdef.zvalue.artpadding  = 0.1;
    cfg.artfctdef.zvalue.fltpadding  = 0;
    cfg.artfctdef.zvalue.bpfilter    = 'yes';
    cfg.artfctdef.zvalue.bpfilttype  = 'but';
    cfg.artfctdef.zvalue.bpfreq      = [2 15]; 
    cfg.artfctdef.zvalue.bpfiltord   = 4;
    cfg.artfctdef.zvalue.hilbert     = 'yes';
    cfg.artfctdef.zvalue.interactive = 'no';
    
    [~, art] = ft_artifact_zvalue(cfg,dat);
    
    
    % which segments were labelled as artefactual?
    cfg                             = [];
    cfg.artfctdef.reject            = 'nan';
    cfg.artfctdef.eog.artifact      = art;
    datnan                          = ft_rejectartifact(cfg,dat);
    
    % prepare an array which contains nans at the artefactual segments
    datxnan = cat(2,datnan.trial{:})';
    
    opts.artseg = find(isnan(datxnan(:,1)));
    
    fprintf('\n Using Fieldtrip to detect EOG-artifacts')
    
else
    fprintf('\n using user-specified artefactual segment labels')
end



% prep a new array that only contains the artefactual segments
datxa   = datx(opts.artseg,:);


% estimate empirical covariance matrices
ca      = datxa'*datxa;
cr      = datx'*datx;


[w,pwr0,pwr1] = nt_dss0(cr,ca);

% compute power (per dss component) ratio between baseline and biased
p1      = pwr1./pwr0;

% define how many components we are interested based on this power ratio
kr      = find(p1/max(p1) > opts.pthresh);

% select only the top dss components
w       = w(:,kr);

% we can now project down to eog components
% eog = datx*w;
% and project back:
% eog * pinv(eog'*eog)*eog'*datx = eog * pinv(w'*datx'*datx*w)*w'*datx'*datx =
% eog * pinv(w'*cxx * w)*w'*cxx = datx * w * pinv(w'*cxx * w)*w'*cxx


% this filter can now be used to regress out eog artifacts, but it'll only
% work well when the data has been centered. there are various reasons why
% future researchers may consider regularization etc, but for our purposes
% we focus on this simple implementation
wd = w * pinv(w'* ca * w) * w' * ca;


if opts.demean
% project back to sensor space but regress out eog artifacts. note that we
% shift the data such that it is not necessarily zero mean anymore
for tt = 1 : numel(dat.trial)
    dat.trial{tt} = bsxfun(@plus,dat.trial{tt}'-dat.trial{tt}'*wd,mu)';
end

else

for tt = 1 : numel(dat.trial)
    dat.trial{tt} = (dat.trial{tt}'-dat.trial{tt}'*wd)';
end

end

out = struct;
out.wd = wd;
out.mu = mu;
out.opts = opts;


end


