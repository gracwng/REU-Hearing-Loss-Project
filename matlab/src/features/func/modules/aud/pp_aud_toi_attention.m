%> @file  pp_aud_toi_attention.m
%> @brief Truncate audio data from each trial from 6 s to 43 s post trigger

function dat = pp_aud_toi_attention(dat)

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


idx = find(dat.t<=43 & dat.t>=6);

dat.t = dat.t(idx);
dat.feat = dat.feat(idx,:);

if ~any(strcmp(fn,'opts'))
    dat.opts = struct;
end

dat.opts.(fstr) = struct;
dat.opts.(fstr).idx = idx;
