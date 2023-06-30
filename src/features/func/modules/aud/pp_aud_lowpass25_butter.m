%> @file  pp_aud_lowpass25_butter.m
%> @brief Low-pass audio feature with a 3rd order Butterworth filter with a
%> cutoff at 25 Hz. This was used during peer review process. 


function dat = pp_aud_lowpass25_butter(dat);

st = dbstack;
fstr = st.name;

fn  = fieldnames(dat);
if any(strcmp(fn,'fs'))
else
    error('No sampling rate specified');
end

fc  = 25;
n   = 3;
causal = 0;
[bl,al] = butter(n,fc/(dat.fs/2));

% note that we here use filtfilt 
xx = filtfilt(bl,al,dat.feat);


dat.feat = xx;

if ~any(strcmp(fn,'opts'))
    dat.opts = struct;
end

dat.opts.(fstr) = struct;
dat.opts.(fstr).fc = fc;
dat.opts.(fstr).n = n;
dat.opts.(fstr).causal = causal;
dat.opts.(fstr).input = struct;
dat.opts.(fstr).input.fs = dat.fs;

end
