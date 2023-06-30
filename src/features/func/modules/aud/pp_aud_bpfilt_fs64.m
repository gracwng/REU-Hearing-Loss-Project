%> @file  pp_aud_bpfilt_fs64.m
%> @brief Bandpass filter audio data with consecutive highpass filtering
%> and lowpass filtering. 
%
%> history:
%> 2019/07/24 this function has not yet been used
%
%
% example usage:
% hold off
% close all
% hold on
% for fc = 2 : 2 : 10
%     
%     
%     dat = struct;
%     dat.fs = fs;
%     dat.feat = zeros(dat.fs*10,1);
%     dat.feat(dat.fs*2)=1;
%     dat.t = [0:1/dat.fs:size(dat.feat,1)/dat.fs-1/dat.fs]';
%     
%     global fbp
%     fbp = [fc-1 fc+1];
%     
%     dat = pp_aud_bpfilt_fs64(dat);
%     N = numel(dat.feat);
%     plot([0:N-1]'*fs/N,20*log10(abs(fft(dat.feat,N))));
%     ylim([-50 0])
%     hold on
% end


function dat = pp_aud_bpfilt_fs64(dat)

st = dbstack;
fstr = st.name;

fn  = fieldnames(dat);
if any(strcmp(fn,'fs'))
    if dat.fs ~= 64
        dbstack
        error('Please ensure that the sampling rate is adequate');
    end
else
    error('No sampling rate specified');
end

global fbp


mhp = esthammingwinfirfiltorder(fbp(1),dat.fs);
mlp = esthammingwinfirfiltorder(fbp(2),dat.fs);
causal = 0;


xx  = matfiltfirzerophase(dat.feat,dat.fs,mhp,fbp(1),causal,'high');


xx  = matfiltfirzerophase(xx,dat.fs,mlp,fbp(2),causal,'low');

dat.feat = xx;

if ~any(strcmp(fn,'opts'))
    dat.opts = struct;
end

dat.opts.(fstr) = struct;
dat.opts.(fstr).fc = fbp;
dat.opts.(fstr).n = [mhp mlp];
dat.opts.(fstr).causal = causal;
dat.opts.(fstr).input = struct;
dat.opts.(fstr).input.fs = dat.fs;

end



















function m = esthammingwinfirfiltorder(fc,fs)
% Estimate zero-phase Hamming-windowed sinc FIR filter order using a 
% heuristic suggested by [1]:  "estimate a filter order providing  a  
% transition  bandwidth  of  25%  of the lower passband edge but, where 
% possible, not lower than 2Hz and  otherwise the distance from the 
% pass-band edge to  the critical frequency (DC, Nyquist)."
%
% Please note that this function currently does not work well for bandpass
% filtering (unless it is realized with a consecutive highpass and lowpass)

%
% References:
%	[1] Widdman et al., (2014) - Digital filterdesignfor electrophysiological data ? a practical approach
%       http://home.uni-leipzig.de/~biocog/eprints/widmann_a2015jneuroscimeth250_34.pdf
%
%   [2] Hamdy, Nadder. Applied Signal Processing: Concepts, Circuits, and Systems. CRC Press, 2008.
%
%           <---------------------------->
% <-------->
%
% |        fc                           fs/2
% |   |    |_____________________________|
% |   |    /                             |
% |   |   /                              |
% |   |  /                               |
%  -------------------------------------------------
%    
%
%      <--->
%     tw>=2 Hz

se      = min([fc*2 (fs/2-fc)*2]);

% transition bandwidth should be 25 % of the lower passband edge
tw      = fc*0.25;

% ... but not lower than 2 Hz
tw      = max([tw 2]);

% ... this may not be reliasable if the distance from passband edge to the 
% critical frequency is too low. take this into account:
tw      = min([tw se]);


% the hamming window filter has a normalized transition width of 3.3 (see
% [2] p 291 or [1] p 8:
m       = 3.3/(tw/fs);


% now we just need to make it even
m       = ceil(m/2)*2;
end