%> @file  pp_aud_resample128_12000.m
%> @brief Resamples audio feature to 128 Hz (using <preproc_resample>). This was used during peer review process. 

function dat = pp_aud_resample128_12000(dat)

st = dbstack;
fstr = st.name;


fn  = fieldnames(dat);
if any(strcmp(fn,'fs'))
    if dat.fs ~= 12000
        dbstack
        %error('Please ensure that the sampling rate is adequate');
    end
else
    error('No sampling rate specified');
end


fsr = 128;
[xr,tn]=preproc_resample(dat.feat,fsr,dat.fs,dat.t(1));

% if numel(find(dat.t<=43 & dat.t>=6))==7400
%     pause
% end

nr  = size(xr,1);


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
