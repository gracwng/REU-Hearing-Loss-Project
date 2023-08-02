%> @file  estcorr.m
%> @brief Compute the product-moment correlation coefficient column-wise between two 2d matrices
%> @param x is a matrix of dimensions (time x columns)
%> @param y is a matrix of dimensions (time x columns)
%> @retval r a vector of product-moment correlations

%> This function is used to compute the product-moment correlation 
%> coefficient between two matrices. This is done column-wise. The computation
%> can be substantially faster than build-in Matlab alternatives when x and y
%> has numerous columns


function [r,p] = estcorr(xx,yy,tail)

if nargin < 1 || isempty(xx);       error('Not enough inputs'); end
if nargin < 2 || isempty(yy);       error('Not enough inputs'); end
if nargin < 3 || isempty(tail);     tail = 'both'; end

cent      = @(dat)bsxfun(@minus,dat,mean(dat));

xcentered = cent(xx);
ycentered = cent(yy);

r         = dot(xcentered,ycentered)./sqrt(sum(xcentered.^2).*sum(ycentered.^2));


if nargout > 1
    % WARNING: the following computation does not take into account multiple comparisons. This should be taken with a grain of salt and corrected for afterwards
    n = size(xx,1);
    dof = n-2;
    t = r .* sqrt((dof)./(1-r.^2));
    
    switch tail
        case 'both'
            p = 2*tcdf(-abs(t),dof);
        case 'right'
            p = tcdf(-t,dof);
        case 'left'
            p = tcdf(t,dof);
    end
warning('Remember to correct for multiple comparisons')
end