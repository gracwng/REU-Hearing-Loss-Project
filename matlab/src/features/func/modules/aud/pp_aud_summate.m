%> @file  pp_aud_summate.m
%> @brief Summates audio feature column-wise (sum(x,2))


function dat = pp_aud_summate(dat)

st = dbstack;
fstr = st.name;

fn  = fieldnames(dat);
if ~any(strcmp(fn,'fs'))
    error('No sampling rate specified');
end


xx  = squeeze(sum(dat.feat,2));

dat.feat = xx;

if ~any(strcmp(fn,'opts'))
    dat.opts = struct;
end
dat.opts.(fstr) = struct;
