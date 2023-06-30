%> @file regevalloosvdridge.m
%> @brief Fits Ridge regression models using <regfitsvdridge> and evaluates the predictive power using a leave-one-trial-out cross-validation technique
%> @param opts configuration struct
%> @param opts.lambda Ridge regularization hyperparameters of interest. Default: [10 100 1000]
%> @param opts.znormd Should the data be Z-scored?. Default: 1 (yes). Alternatively set it to 0 (no)
%> @param opts.gof What goodness-of-fit metric is considered? default:
%> 'estcorr'. Please note that this is an advanced field and should most often be left
%> as is.
%> @param xx regressor matrix of size (time x features x trials)
%> @param yy target matrix of size (time x features x trials)
%> @retval ww model weights for the model that yield best goodness-of-fit during cross-validation
%> @retval acc prediction accuracy after averaging over all outer folds for
%> each lambda and selecting the maximum (please note that this may show
%> signs of overfitting and should thus be taken with a grain of salt, and we
%> did not use this measure)


function [ww,acc] = regevalloosvdridge(opts,xx,yy)

if nargin < 1 || isempty(opts);        opts = struct; end
if isfield(opts,'lambda')==0;          opts.lambda = [10 100 1000]; end
if isfield(opts,'znormd')==0;          opts.znormd = 1; end
if isfield(opts,'gof')==0;             opts.gof = 'estcorr'; end

ko      = size(xx,3);
acc     = [];

for jo  = 1 : ko
    
    traino  = setdiff(1:ko,jo);
    valo    = jo;
    
    xtr     = matsqueeze3d2d(xx(:,:,traino));
    ytr     = matsqueeze3d2d(yy(:,:,traino));
    
    xvl     = matsqueeze3d2d(xx(:,:,valo));
    yvl     = matsqueeze3d2d(yy(:,:,valo));
    
    
    acc(:,:,jo) = regfitsvdridge(xtr,ytr,xvl,yvl,opts.lambda,opts.znormd,opts.gof);
end

[acc,accoopt] = max(mean(acc,3),[],1);


xx     = matsqueeze3d2d(xx);
yy     = matsqueeze3d2d(yy);

[~,ww] = regevaloptimallambdasvdridge(xx,yy,[],[],accoopt,opts.lambda,opts.znormd,opts.gof);


end