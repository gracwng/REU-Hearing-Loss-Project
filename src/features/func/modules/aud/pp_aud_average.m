%> @file  pp_aud_average.m
%> @brief Average audio feature across columns

function dat = pp_aud_average(dat)

st = dbstack;
fstr = st.name;

fn  = fieldnames(dat);
if ~any(strcmp(fn,'fs'))
    error('No sampling rate specified');
end


xx  = squeeze(mean(dat.feat,2));

dat.feat = xx;

if ~any(strcmp(fn,'opts'))
    dat.opts = struct;
end
dat.opts.(fstr) = struct;
