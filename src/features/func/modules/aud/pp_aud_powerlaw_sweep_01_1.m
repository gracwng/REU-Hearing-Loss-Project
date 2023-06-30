%> @file  pp_aud_powerlaw_sweep_01_1.m
%> @brief Power-law compress audio feature (abs(x).^c.*sign(x)) with a
%> range of compressive factors (0.1, 0.2, 0.3, 0.4 .... 1) and stack audio
%> features along third dimension

function dat = pp_aud_powerlaw_sweep_01_1(dat);

st = dbstack;
fstr = st.name;

fn  = fieldnames(dat);
if ~any(strcmp(fn,'fs'))
    error('No sampling rate specified');
end

c = [0.1:0.1:1];
xx = [];
for i = 1 : numel(c)
xx(:,:,i) = abs(dat.feat).^c(i).*sign(dat.feat);
end

dat.feat = xx;

if ~any(strcmp(fn,'opts'))
    dat.opts = struct;
end
dat.opts.(fstr) = struct;
dat.opts.(fstr).c = c;
