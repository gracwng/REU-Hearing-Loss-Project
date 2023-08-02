%> @file  pp_aud_halfwave_rectify.m
%> @brief Half-wave rectify audio feature. This was used during peer review process. 

function dat = pp_aud_halfwave_rectify(dat);

st = dbstack;
fstr = st.name;

fn  = fieldnames(dat);
if ~any(strcmp(fn,'fs'))
    error('No sampling rate specified');
end

dat.feat         = max(dat.feat,0);


if ~any(strcmp(fn,'opts'))
    dat.opts = struct;
end
dat.opts.(fstr) = struct;
