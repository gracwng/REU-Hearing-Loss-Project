%> @file  pp_aud_resample12000_44100.m
%> @brief Resamples audio feature to 12000 Hz (using <preproc_resample>)

function dat = pp_aud_resample12000_44100(dat)

st = dbstack;
fstr = st.name;


fn  = fieldnames(dat);
if any(strcmp(fn,'fs'))
    if dat.fs ~= 44100
        dbstack
        error('Please ensure that the sampling rate is adequate');
    end
else
    error('No sampling rate specified');
end


fsr     = 12000;
[xr,tn] = preproc_resample(dat.feat,fsr,dat.fs,dat.t(1));
nr      = size(xr,1);


if ~any(strcmp(fn,'opts'))
    dat.opts = struct;
end

dat.opts.(fstr) = struct;
dat.opts.(fstr).fsr = fsr;
dat.opts.(fstr).input = struct;
dat.opts.(fstr).input.fs = dat.fs;


dat.fs = fsr;
dat.feat = xr;
dat.t = tn(:);
