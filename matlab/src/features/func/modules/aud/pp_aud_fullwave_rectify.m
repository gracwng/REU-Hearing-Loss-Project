%> @file  pp_aud_fullwave_rectify.m
%> @brief Fullwave rectify audio feature

function dat = pp_aud_fullwave_rectify(dat);

st = dbstack;
fstr = st.name;

fn  = fieldnames(dat);
if ~any(strcmp(fn,'fs'))
    error('No sampling rate specified');
end

dat.feat         = abs(dat.feat);


if ~any(strcmp(fn,'opts'))
    dat.opts = struct;
end
dat.opts.(fstr) = struct;
