%> @file  pp_aud_firstorder_diff.m
%> @brief Compute the first order difference for an audio feature. This was used during peer review process. 

function dat = pp_aud_firstorder_diff(dat)

st = dbstack;
fstr = st.name;

fn  = fieldnames(dat);
if ~any(strcmp(fn,'fs'))
    error('No sampling rate specified');
end

dat.feat         = [zeros(1,size(dat.feat,2)); diff(dat.feat)];


if ~any(strcmp(fn,'opts'))
    dat.opts = struct;
end
dat.opts.(fstr) = struct;
end
