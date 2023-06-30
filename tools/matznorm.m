%> @file  matznorm.m
%> @brief Z-score a matrix to its empirical mean and standard deviation.
%> @param xx input matrix of size (time x features)
%> @param mu (optional) mean to be subtracted from data (1 x features)
%> @param sd (optional) standard deviation to be normalized to (1 x features). This function prevents that small sd values causes standardization to blow up, when sd is calculated from <xx>. 
%> @retval yy z-scored output matrix

function yy = matznorm(xx,mu,sd)

if nargin < 1 || isempty(xx);       error('Not enough inputs'); end
if nargin < 2 || isempty(mu);       mu = []; end
if nargin < 3 || isempty(sd);       sd = []; end


if isempty(mu)
    mu = mean(xx);
end

if isempty(sd)
    sd = std(xx);
    sd = max(sd,max(sd)/1000);
end

yy = bsxfun(@rdivide,bsxfun(@minus,xx,mu),sd);
