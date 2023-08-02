%> @file  pp_aud_hilbert.m
%> @brief Extract the Hilbert envelope by taking the absolute value of the
%> analytic signal. This was used during peer review process. 


function dat = pp_aud_hilbert(dat)

st = dbstack;
fstr = st.name;

fn  = fieldnames(dat);
if ~any(strcmp(fn,'fs'))
    error('No sampling rate specified');
end

dat.feat         = abs(hilbert(dat.feat));


if ~any(strcmp(fn,'opts'))
    dat.opts = struct;
end
dat.opts.(fstr) = struct;
end
