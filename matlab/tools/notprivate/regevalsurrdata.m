%> @file regevalsurrdata.m
%> @brief Evaluate the goodness of fit of a regression model on phase scrambled data.
%> @param xx regressor matrix of size (time x features)
%> @param yy target matrix of size (time x features)
%> @param ww regression coefficients
%> @param np number of permutations
%> @param gof goodness-of-fit metric to be considered (default: 'estcorr').
%> @param roi define a number of columns in <yy> over which the accuracy is averaged over 
%> @retval acc goodness of fit (e.g. correlation coefficient) < number of permutations x dim>
%> @retval roi the number of columns in <yy> that the acc was averaged over

%> history:
%> 2019/07/05 included nargin statements

function [acc,roi] = regevalsurrdata(xx,yy,ww,np,gof,roi)

if nargin < 1 || isempty(xx); error('Please input data'); end
if nargin < 2 || isempty(yy); error('Please input data'); end
if nargin < 3 || isempty(ww); error('Please input regression coefficients'); end
if nargin < 4 || isempty(np); np = 1000; end
if nargin < 5 || isempty(gof); gof = 'estcorr'; end
if nargin < 6 || isempty(gof); roi = []; end

yp = xx*ww;

if rem(size(yp,1),2)~=0
    yp = yp(1:end-1,:);
end


gof = str2func(gof);

acc = [];
for pp = 1 : np
    acc(pp,:) = gof(yp,matphasescramble(yy));
end



if ~isempty(roi)
    
    try
        acc = mean(acc(:,roi),2);
    catch
        roi = 1:size(acc,2);
        acc = mean(acc(:,roi),2);
    end
end


end