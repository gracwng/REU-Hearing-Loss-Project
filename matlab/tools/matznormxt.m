%> @file  matznormxt.m
%> @brief Z-score two matrices <xx> and <xt> to the empirical mean and standard deviation of <xx>
%> @param xx input matrix of size (time x features)
%> @param xt input matrix of size (time x features)
%> @retval xx z-scored <xx> data matrix
%> @retval xt z-scored <xt> output matrix

function [xx,xt] = matznormxt(xx,xt)

if nargin < 1 || isempty(xx);       error('Not enough inputs'); end
if nargin < 2 || isempty(xt);       xt = []; end;

mux     = mean(xx);
stdx    = std(xx);

xx      = matznorm(xx,mux,stdx);

if ~isempty(xt)
    xt  = matznorm(xt,mux,stdx);
end
