%> @file  pp_aud_gammatone.m
%> @brief Passes audio feature through a Gammatone filterbank with
%> ERB-spaced centre frequencies (between 100 Hz and 12 kHz). Note that this
%> function is used as an additional control

function dat = pp_aud_gammatone_highfreq(dat)

st = dbstack;
fstr = st.name;

fn  = fieldnames(dat);
if ~any(strcmp(fn,'fs'))
    error('No sampling rate specified');
end


flow       = 100;
fhigh      = 12000;
fc         = erbspacebw(flow, fhigh);
[gb, ga]   = gammatone(fc, dat.fs, 'complex');

xx         = [];
for ii = 1 : size(dat.feat,2)
xx         = [xx 2*real(ufilterbankz(gb,ga,dat.feat(:,ii)))];
end

dat.feat = xx;


if ~any(strcmp(fn,'opts'))
    dat.opts = struct;
end
dat.opts.(fstr) = struct;
dat.opts.(fstr).fc = fc;
dat.opts.(fstr).flow = flow;
dat.opts.(fstr).fhigh = fhigh;
dat.opts.(fstr).input = struct;
dat.opts.(fstr).input.fs = dat.fs;
