%> @file regevaloptimallambdasvdridge.m
%> @brief Fits Ridge regression models using <regfitsvdridge> with fixed regularization parameters and optionally assesses predictive power on indepent data
%> @param xx regressor matrix of size (time x features)
%> @param yy target matrix of size (time x features)
%> @param xt validation (or test) regressor matrix (time x features)
%> @param yt validation (or test) target matrix (time x features)
%> @param optindex indexes indicating which regularization parameters to
%> consider for each output dimension. If the output from a cross-validation
%> analysis e.g. suggests that lambda=0.1 is optimal for voxel/channel 1 and
%> lambda=10 is optimal for voxel/channel 2 then optindex = [1 3] if lambda=[0.1 1 10]
%> @param lambda regulariation parameters considered
%> @param znormd a flag indication whether or not the data is zscored
%> @param gof goodness-of-fit metric to be considered (default: 'estcorr')
%> @retval acc goodness of fit (e.g. correlation coefficient) 
%> @retval w regression coefficients (number of dimensions in xt x number of dimensions in yt)

%> history:
%> 2019/07/05 included more comments

%> to do: 
%> describe in more details

function [acc,ww] = regevaloptimallambdasvdridge(xx,yy,xt,yt,optindex,lambda,znormd,gof)

if nargin < 1 || isempty(xx);       error('Not enough inputs'); end
if nargin < 2 || isempty(yy);       error('Not enough inputs'); end
if nargin < 3 || isempty(xt);       xt = []; end
if nargin < 4 || isempty(yt);       yt = []; end
if nargin < 5 || isempty(optindex); optindex = 1; end
if nargin < 6 || isempty(lambda);   lambda = 100; end
if nargin < 7 || isempty(znormd);   znormd = 1; end
if nargin < 8 || isempty(gof);   	gof = 'estcorr'; end

acc     = [];
ww       = [];
ndy     = size(yy,2);

if isempty(yt) || isempty(xt)
    evaltest = 0;
else
    evaltest = 1;
end


if evaltest
    
    for nn  = 1 : ndy
        [acc(nn,:), ww(:,nn)] = regfitsvdridge(xx,yy(:,nn),xt,yt(:,nn),lambda(optindex(nn)),znormd,gof);
    end
    
else
    
    for nn  = 1 : ndy
        [~, ww(:,nn)] = regfitsvdridge(xx,yy(:,nn),[],[],lambda(optindex(nn)),znormd,gof);
    end
    
end