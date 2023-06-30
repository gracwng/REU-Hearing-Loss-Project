%> @file  pp_aud_highpass1_64.m
%> @brief High pass filter audio feature with a 1 Hz linear phase FIR filter of order 106 (and adjust for filter delay). 

function dat = pp_aud_highpass1_64(dat);

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


fc  = 1;
n   = 106;
causal = 0;
xx  = matfiltfirzerophase(dat.feat,dat.fs,n,fc,causal,'high');

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

