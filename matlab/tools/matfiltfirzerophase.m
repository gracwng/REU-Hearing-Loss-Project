%> @file  matfiltfirzerophase.m
%> @brief Applies a low- or high-pass linear phase FIR filter to an 2d array
%> and shifts the data to account for filter delays. This function demeans
%> the data, use an endpoint-padding approach and subsequently adds the mean
%> back to the data.
%> @param xx is a matrix of dimensions (time x columns)
%> @param fs sampling rate
%> @param n order of filter (must be even)
%> @param fc 6 dB cutoff frequency
%> @param causal a 0/1 flag. 0 = shift to account for delays, 1 = do not
%> shift. It is important to note that it here is called "causal", but the
%> demeaning does not really fulfill that. note that we never use causal=1 in
%> this project
%> @param type high pass filter ('high') or low-pass filter ('low', default)
%> @retval xf filtered matrix of dimensions (time x columns). 

%> history
%> 2019/15/07 updated comments

function xf = matfiltfirzerophase(xx,fs,n,fc,causal,type)

if nargin < 5 || isempty(causal); causal = 0; end
if nargin < 6 || isempty(type); type = 'low'; end


mu = mean(xx);
xx = bsxfun(@minus, xx, mu);

b = fir1(n,fc/(fs/2),type);

if mod(length(b), 2) ~= 1
   error('filter is not even')
end

gd = (length(b) - 1) / 2;  

if causal
    pb = repmat(xx(1,:), 2*gd,1);
    pe = [];
else
    pb = repmat(xx(1,:), gd,1);
    pe = repmat(xx(end,:),gd,1);
end

xp = [pb; xx; pe];

xf = filter(b, 1, xp); 


xf = xf(2 * gd + 1:end, :);

if strcmp(type,'low')
xf = bsxfun(@plus, xf, mu);
end