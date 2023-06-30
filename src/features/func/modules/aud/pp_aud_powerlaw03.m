%> @file  pp_aud_powerlaw03.m
%> @brief Power-law compress audio feature (abs(x).^0.3.*sign(x)) with a compressive factor of 0.3
function dat = pp_aud_powerlaw03(dat);

st = dbstack;
fstr = st.name;

fn  = fieldnames(dat);
if ~any(strcmp(fn,'fs'))
    error('No sampling rate specified');
end

c = 0.3;
dat.feat         = abs(dat.feat).^c.*sign(dat.feat);


if ~any(strcmp(fn,'opts'))
    dat.opts = struct;
end
dat.opts.(fstr) = struct;
dat.opts.(fstr).c = c;
