%> @file regfitsvdridge.m
%> @brief Fits a Ridge regression model and optionally assesses predictive power on independent data
%> @param xx regressor matrix of size (time x features)
%> @param yy target matrix of size (time x features)
%> @param xt validation (or test) regressor matrix (time x features)
%> @param yt validation (or test) target matrix (time x features)
%> @param lambda regulariation parameters considered
%> @param znormd a flag indication whether or not the data is zscored
%> @param gof goodness-of-fit metric to be considered (default: 'estcorr')
%> @retval acc goodness of fit (e.g. correlation coefficient), with size (number of ridge parameters x number of dimensions in yy)
%> @retval w regression coefficients, (number of dimensions xt x number of dimensions in yt x number of ridge parameters)

%> history
%> 2019/07/05 included more detailed comments


function [acc,w] = regfitsvdridge(xx,yy,xt,yt,lambda,znormd,gof)

if nargin < 1 || isempty(xx);       error('Not enough inputs'); end
if nargin < 2 || isempty(yy);       error('Not enough inputs'); end
if nargin < 3 || isempty(xt);       xt = []; end
if nargin < 4 || isempty(yt);       yt = []; end
if nargin < 5 || isempty(lambda);   lambda = 100; end
if nargin < 6 || isempty(znormd);   znormd = 1; end
if nargin < 7 || isempty(gof);   	gof = 'estcorr'; end

gof = str2func(gof);


if ~isempty(xt) && ~isempty(yt)
    evaltest = 1;
else
    evaltest = 0;
end

if znormd 
    [xx,xt] = matznormxt(xx,xt);
    [yy,yt] = matznormxt(yy,yt);
end

[u,s,v] = svd(xx,'econ');

nk      = diag(s)>eps;
ns      = size(xx,1);

u       = u(:,nk);
s       = s(:,nk);
v       = v(:,nk);

cuy     = u'*yy;

if evaltest
    cxt = xt*v;
end



acc     = nan(numel(lambda),size(yt,2)); 

if nargout > 1
    w   = [];
end

for n = 1 : numel(lambda)
    
    
    d   = diag(diag(s)./(diag(s).^2+lambda(n)));
    
    if nargout > 1
        w(:,:,n) = v*d*cuy;
    end
    
    if evaltest
        pred = cxt*d*cuy;    
        acc(n,:) = gof(pred,yt);
    end
    
end




end
