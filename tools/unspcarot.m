%> @file unspcarot.m
%> @brief Performs principal component analysis 
%> @param x a matrix of size [time x features]
%> @param method a string ('eig' or 'svd') specifying what implementaiton
%> to consider
%> @retval w whitening matrix
%> @retval pcs principal components (rotation matrix)
%> @retval vr eigenvalues

%> Please note that this function does not center or standardize the data

function [w,pcs,vr] = unspcarot(x,method)

if nargin < 2 || isempty(method); method = 'eig'; end

n = size(x,1);

if strcmp(method,'eig')
    
    c = x'*x/n;

    % perform an eigendecomposition
    [v, d] = eig(c);
    
    % sort it
    [val, ind] = sort(diag(d)', 'descend');
      
    % estimate rotation matrix
    pcs = v(:,ind);
    
    % variances of the pcs
    vr = diag(val);
    
    % whitening matrix
    w = pcs*diag(real(val.^(-0.5))); 
end

if strcmp(method,'svd')
    
    
    % use svd
    [u,s,v] = svd(x,0);
    
    vr = (1/n)*diag(s).^2;
    
    vr = diag(vr);

    pcs = v;
    
    w = pcs * diag(real(diag(vr).^(-0.5))); 

    
end