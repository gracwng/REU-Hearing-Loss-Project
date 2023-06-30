%> @file  matphasescramble.m
%> @brief Phase scramble data but preserve Fourier spectra and correlation structure
%> @param xx is a matrix of dimensions (time x columns)
%> @retval yy phase scrambled data
%
%
%> References:
%>
%> Prichard, Dean, and James Theiler. "Generating surrogate data for time 
%> series with several simultaneously measured variables." Physical review 
%> letters 73.7 (1994): 951.
%>
%>
%> Theiler, James, et al. "Testing for nonlinearity in time series: the
%> method of surrogate data." Physica D: Nonlinear Phenomena 58.1-4 (1992): 77-94.
%> The MIT License (MIT)
%>
%> history
%> 2019/15/07 updated comments

% example:
% rng(1)
% xx = randn(10000,10);
% yy = matphasescramble(xx);
% sum(sum(abs(corrcoef(xx)-corrcoef(yy)).^2))
% sum(sum(abs(abs(fft(xx))-abs(fft(yy))).^2))


function yy = matphasescramble(xx)

if rem(size(xx,1),2)==1
    xx = xx(1:end-1,:);
end

[n,m]       = size(xx);
nh          = ceil(n/2);

xxfft       = fft(xx);
xxfftamp    = abs(xxfft);
xxfftphi    = angle(xxfft);


% note that we add the same random sequence to preserve autocorrelation and
% crosscorrelations
phiss       = repmat(2*pi*rand(nh,1)-pi,1,m);

yypr        = xxfftamp(2:nh+1,:).*exp(1j*(xxfftphi(2:nh+1,:)+phiss));

yyfft       = xxfft;
yyfft(2:nh,:) = yypr(1:end-1,:);
yyfft(nh+2:end,:) = conj(yypr(nh-1:-1:1,:));

yy          = ifft(yyfft);

