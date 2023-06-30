%> @file  r01f08
%> @brief Exports ITPC spectra computed based on DFT
%> @param sdir directory in which the derived data is stored
%> @param bidsdir directory in which the source data is stored
%> @param do_plot a flag (1/0) indicating whether or not you want to
%> plot the output.


function dtab = r01f08(sdir,bidsdir,do_plot,do_denoise)

if nargin < 1 || isempty(sdir);     sdir    = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/'; end
if nargin < 2 || isempty(bidsdir);  bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end
if nargin < 3 || isempty(do_plot);  do_plot = 1; end
if nargin < 4 || isempty(do_denoise);  do_denoise = 1; end

participants_tsv = ioreadbidstsv(fullfile(bidsdir,'participants.tsv'));

itpc_dg = []; itpc_g = [];
roi = 1 : 64;
for subid = 1 : 44
    
    
    workflows_paper
    rng('default'); parcreaterandstream(44, randi(10000)+subid)
    
    fprintf('\n importing data from sub-%0.3i',subid)
    
    load(fullfile(sdir,'features','eeg',sprintf('sub-%0.3i_eeg-%s.mat',subid,pipeline_dg_itpc.sname)))
    
    
    if do_denoise
        dat = pp_ft_eogdenoise(dat);
    end
    
    
    %For this analysis, we truncate the data between 0.2 s and 2.5 s post
    %stimulus
    cfg = [];
    cfg.latency = [-0.5 2.5];
    dat = ft_selectdata(cfg,dat);
    
    
    
    id_trig_dg = find(dat.trialinfo==192);
    id_trig_g = find(dat.trialinfo==224);
    
    
    cfg = [];
    cfg.method      = 'mtmfft';
    cfg.trials      = id_trig_dg;
    cfg.output      = 'fourier';
    cfg.channel     = 'EEG';
    cfg.pad         = 'nextpow2';
    cfg.taper       = 'hanning';
    [freq_dg]       = ft_freqanalysis(cfg, dat);
    
    
    
    cfg = [];
    cfg.method      = 'mtmfft';
    cfg.trials      = id_trig_g;
    cfg.output      = 'fourier';
    cfg.channel     = 'EEG';
    cfg.pad         = 'nextpow2';
    cfg.taper       = 'hanning';
    [freq_g]       = ft_freqanalysis(cfg, dat);
    
    
    
    itpc_fun = @(x) squeeze(abs(mean(x./abs(x),1)));
    
    itpc_dg(:,:,subid)   = itpc_fun(freq_dg.fourierspctrm);
    itpc_g(:,:,subid)    = itpc_fun(freq_g.fourierspctrm);
    
    freq_dg.fourierspctrm = [];
    freq_g.fourierspctrm = [];
    
    
    
    datitpc{subid,1} = freq_dg;
    datitpc{subid,2} = freq_g;
    
    
end


if do_plot
    plot_freq_errorbars(itpc_g,itpc_dg,participants_tsv,roi,datitpc)
    
    cd(fullfile(fileparts(which('initdir.m'))))
    print(fullfile(pwd,'reports','review','review01','fig08','r01f08a.pdf'),'-dpdf','-r0')

    plot_barplots(itpc_g,itpc_dg,participants_tsv,roi,datitpc)
     
    cd(fullfile(fileparts(which('initdir.m'))))
    print(fullfile(pwd,'reports','review','review01','fig08','r01f08b.pdf'),'-dpdf','-r0')

end

end


function plot_freq_errorbars(itpc_g,itpc_dg,participants_tsv,roi,datitpc)

cphi = strcmp(participants_tsv.hearing_status,'hi');
cpnh = strcmp(participants_tsv.hearing_status,'nh');

figure

for sb = 1 : 2
    
    if sb == 1
        dplot = mean(itpc_dg(roi,:,:),1);
        fhz = datitpc{1}.freq;
        xl = [1 9];
    elseif sb == 2
        dplot = mean(itpc_g(roi,:,:),1);
        fhz = datitpc{1}.freq;
        xl = [37 45];
    end
    cmp =  [0.7020    0.8039    0.8902; ...
        0.9843    0.7059    0.6824];
    
    
    
    subplot(2,1,sb)  
    h1 = shadedErrorBar(fhz,mean(dplot(:,:,cpnh),3),std(dplot(:,:,cpnh),[],3)/sqrt(sum(cpnh)),'lineprops',{'-','Color',cmp(1,:),'MarkerFaceColor',cmp(1,:)});
    hold on
    h2 = shadedErrorBar(fhz,mean(dplot(:,:,cphi),3),std(dplot(:,:,cphi),[],3)/sqrt(sum(cphi)),'lineprops',{'-','Color',cmp(2,:),'MarkerFaceColor',cmp(2,:)});
    
    xlabel('Frequency (Hz)')
    ylabel('ITPC')
    
    
    hl = line([4 4],[0 0.2]); hl.Color = 'k'; hl.LineStyle = '--';
    hl = line([40 40],[0 0.2]); hl.Color = 'k'; hl.LineStyle = '--';
   
    ylim([0.08 0.45])
    xlim(xl)

    box off
    
    set(gca,'TickDir','out');
    set(gca,'TickLength',[0.03, 2]*1)
    
end
set(gca,'Fontsize',8)
fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [2.9996 2.9996 3.5560 7.3539];


end



function plot_barplots(itpc_g,itpc_dg,participants_tsv,roi,datitpc)

cmp =  [0.7020    0.8039    0.8902; ...
    0.9843    0.7059    0.6824];

figure

cphi = strcmp(participants_tsv.hearing_status,'hi');
cpnh = strcmp(participants_tsv.hearing_status,'nh');


for sb = 1 : 2
    if sb == 1
        dplot   = mean(itpc_dg(roi,:,:),1);
        fhz     = datitpc{1}.freq;
        xl      = [1 15];
        fid     = find(fhz==4);
        yl      = 'ITPC (4 Hz)';
    elseif sb == 2
        dplot   = mean(itpc_g(roi,:,:),1);
        fhz     = datitpc{1}.freq;
        xl      = [31 45];
        fid     = find(fhz==40);
        yl      = 'ITPC (40 Hz)';
        
    end
    
    xnh         = squeeze(dplot(:,fid,cpnh));
    xhi         = squeeze(dplot(:,fid,cphi));
    
    
    subplot(2,1,sb)
    
    bar(1,mean(xnh),'FaceColor',cmp(1,:))
    hold on
    bar(2,mean(xhi),'FaceColor',cmp(2,:))
    
    hold on
    errorbar(1,mean(xnh),std(xnh)/sqrt(size(xnh,1)),'.k')
    errorbar(2,mean(xhi),std(xhi)/sqrt(size(xhi,1)),'.k')
    
    plot(ones(size(xnh,1),1)+randn(size(xnh,1),1)*0.05,xnh,'.','Color',[0.8 0.8 0.8])
    plot(ones(size(xnh,1),1)+1+randn(size(xhi,1),1)*0.05,xhi,'.','Color',[0.8 0.8 0.8])
    
    set(gca,'xtick',1:2)
    set(gca,'xticklabel',{'NH','HI'})
    
    ylim([0.08 0.6])
    box off
    ylabel(yl)
    
    set(gca,'TickDir','out');
    set(gca,'TickLength',[0.03, 2]*1)
    
end
set(gca,'Fontsize',8)
fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [3 3 3 7.3539];



end