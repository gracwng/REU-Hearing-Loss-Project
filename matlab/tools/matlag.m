%> @file matlag.m
%> @brief Creates a lagged (time-shifted) version of a 2d array
%> @param xx input matrix of size (time xx features)
%> @param lags a vector or a value that contains the time-shifts of interest (in samples). Negative lags leads the xx matrix and positive lags the matrix.

%> Please note that this function is not well-suited for fitting
%> multidimensional stimulus-response for certain types of regularization
%> that enforce smoothness along certain dimensions (e.g. Tikhonov
%> regularization or Gaussian Process Priors). Here, it is possible that
%> the model instead will put a constraint on the smoothness across
%> neighbouring channels (for decoding models) or peripheral bands (for
%> spectro-temporal receptive field models).

function [lmat] = matlag(xx,lags)

if nargin < 1 || isempty(xx);       error('No input provided input'); end
if nargin < 2 || isempty(lags);     lags = 0; end

ns        = size(xx,1);
nch       = size(xx,2);
lmat      = zeros(ns,nch*length(lags));

for ii = 1 : numel(lags)
    
    cshift = (1:nch)+(ii-1)*nch;
    l = circshift(xx,lags(ii));
    
    if lags(ii) >=0
        l(1:lags(ii),:) = 0;
    else
        l((end+lags(ii)+1):end,:) = 0;
    end
    
    lmat(:,cshift) = l;
end



end