%> @file  extract_itpc_results.m
%> @brief Extract results from ITPC analysis and exports panels in figure 5


%> history
%> 2019/07/08 added comments and doplot option
%> 2019/07/24 updated nargin

function dtab = extract_itpc_results(sdir,bidsdir,pipeline_dg_itpc,doplot)

if nargin < 1 || isempty(sdir);     sdir    = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/'; end
if nargin < 2 || isempty(bidsdir);  bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end
if nargin < 4 || isempty(doplot);   doplot  = 1; end

% import the BIDs events file which contains information about each
% participant and their hearing status (<nh> or <hi>)
participants_tsv = ioreadbidstsv(fullfile(bidsdir,'participants.tsv'));


for subid = 1 : 44
    
    % import data
    fprintf('\n proccesing data from subject %i of %i',subid,44)
    clear itc_cond
    fname = fullfile(sdir,'results',sprintf('sub-%0.3i_itpc_%s-%s.mat',subid,pipeline_dg_itpc.task,pipeline_dg_itpc.sname));
    load(fname);
    
    
    % the results from the ITPC analysis were stored in a cellstruct
    itpc_dg = cat(3,itc_cond{1,:});
    itpc_g  = cat(3,itc_cond{2,:});
    
    
    % check that everything is in order before exporting the results. the
    % entries <freq>, <time> and <label> should be identical for the two
    % experimental conditions
    freq_dg = cat(1,itpc_dg.freq);
    freq_g = cat(1,itpc_g.freq);
    
    time_dg = cat(1,itpc_dg.time);
    time_g = cat(1,itpc_g.time);
    
    label_dg = cat(2,itpc_dg.label);
    label_g = cat(2,itpc_g.label);
    
    if abs(sum(freq_dg-freq_g))~=0 | abs(sum(time_dg-time_g))~=0
        error('something went wrong!')
    end
    
    if any(sum(ismember(time_dg',unique(time_dg(:))))~=numel(unique(time_dg(:))))
        error('something is wrong!')
    end
    
    if any(sum(ismember(label_dg,unique(label_dg(:))))~=numel(unique(label_dg(:))))
        error('something is wrong!')
    end
    
    % now that we know that <freq>, <time> and <label> are identical, we 
    % focus on only one of them
    freq = freq_dg;
    time = time_dg(1,:);
    label = label_dg;
    
    % prepare the itpc [channel x time x freq ] matrices
    itpc_dg = cat(3,itpc_dg.itpc); % size: [64 513 119]
    itpc_g = cat(3,itpc_g.itpc);
    
    % figure out which elements that correspond to 4 Hz and 40 Hz ITPC
    [~,i4hz]=min(abs(freq-4));
    [~,i40hz]=min(abs(freq-40));
    
    
    
    % for the statistical analysis we bin the data into non-overlapping
    % windows from [0-0.5, 0.5-1? 1-1.5, 1.5-2] s. we do so for the 4 Hz
    % ITPC for delta-gamma data and 40 Hz ITPC for gamma data
    for ti = 1 : 4
        time_index = find(time>=(0+(ti-1)*0.5) & time < 0.5+(ti-1)*0.5);
        
        itpc_4_hz_dg(subid,ti)  = mean(mean(itpc_dg(:,time_index,i4hz)));
        itpc_40_hz_g(subid,ti)  = mean(mean(itpc_g(:,time_index,i40hz)));
        
        % additionally, we also prepare ticks for figures
        xticks{subid,ti} = sprintf('%0.1fs-%0.1fs',time(time_index(1)),time(time_index(end)));
    end
    
    % for the topographical depictions we average everything over 0-2 s
    % (including endpoints). this is done for the 4 Hz
    % ITPC for delta-gamma data and 40 Hz ITPC for gamma data
    itpc_topo_dg(subid,:) = mean(mean(itpc_dg(:,time>=0 & time <= 2,i4hz),2),3);
    itpc_topo_g(subid,:)  = mean(mean(itpc_g(:,time>=0 & time <= 2,i40hz),2),3);
    
    
    % finally, we also export time-frequency illustration of the effects.
    % in this case we average over all 64 electrodes
    itpc_timefreq_dg(subid,:,:)  = squeeze(mean(itpc_dg,1));
    itpc_timefreq_g(subid,:,:)  = squeeze(mean(itpc_g,1));
    
    
end

if doplot
export_itpc_topographies(participants_tsv,itpc_topo_dg,itpc_topo_g)
export_itpc_time_frequency_plots(time,freq,participants_tsv,itpc_timefreq_dg,itpc_timefreq_g)
end

% prepare the <dtab> table
dtab = table(participants_tsv.participant_id,participants_tsv.hearing_status,itpc_4_hz_dg,itpc_40_hz_g,xticks);
dtab.Properties.VariableNames = {'participant_id','hearing_status','delta_gamma_itpc','gamma_itpc','itpc_time_labels'};

if doplot
export_itpc_time_averages(participants_tsv,dtab)
end
end























function export_itpc_topographies(participants_tsv,itpc_topo_dg,itpc_topo_g)

nhid = strcmp(participants_tsv.hearing_status,'nh');
hiid = strcmp(participants_tsv.hearing_status,'hi');

cd(fullfile(fileparts(which('initdir.m')),'reports','paper','fig5'))
pause(0.5)


for i = 1 : 4   
    switch i
        
        case 1
            dplot   = mean(itpc_topo_dg(hiid,:));
            fn      = {'delta_gamma','hi'};
        case 2
            dplot   = mean(itpc_topo_dg(nhid,:));
            fn      = {'delta_gamma','nh'};
        case 3
            dplot   = mean(itpc_topo_g(hiid,:));
            fn      = {'gamma','hi'};
        case 4
            dplot   = mean(itpc_topo_g(nhid,:));
            fn      = {'gamma','nh'};
    end
    
    close all

    figure
    fig = get(groot,'CurrentFigure');
    set(fig, 'Units', 'centimeters')
    fig.Position = [3 3 1.875 1.875];
    load('rdbu.mat'); colormap(cmap);
    
    cfg=[];
    cfg.layout='biosemi64.lay';
    layout=ft_prepare_layout(cfg);
    
    ft_plot_topo(layout.pos(1:numel(dplot),1), layout.pos(1:numel(dplot),2), dplot',...
        'mask', layout.mask,...
        'outline', layout.outline, ...
        'interplim', 'mask','isolines',3,'style','imsatiso','clim',[0.04 0.35]);
    
    lineObj = findobj(gca, 'type', 'line');
    for l = 1:length(lineObj)
        if get(lineObj(l), 'LineWidth') > 0.5
            set(lineObj(l), 'LineWidth', 0.5);
        end
    end
    
    axis off; axis equal  
    load('rdbu.mat')
    colormap(cmap);
    
    print(sprintf('figure-05-p%0.3i-cond-%s-group-%s.pdf',i+6,fn{1},fn{2}),'-dpdf')
    
    if i == 4
        cb = colorbar;
        fig = get(groot,'CurrentFigure');
        set(fig, 'Units', 'centimeters')
        fig.Position = [3 3 4.725 4.725];
        cb = colorbar('southoutside');        
        set(gca,'fontsize',8)
        print('figure-05-p011-legend.pdf','-dpdf','-r500')

    end

end


end
















function export_itpc_time_frequency_plots(time,freq,participants_tsv,itpc_timefreq_dg,itpc_timefreq_g)


time_index = find(time>-0.5 & time < 2.5);

nhid = strcmp(participants_tsv.hearing_status,'nh');
hiid = strcmp(participants_tsv.hearing_status,'hi');


for i = 1 : 4
    
    
    switch i
        
        case 1
            dplot = squeeze(mean(itpc_timefreq_dg(nhid,time_index,:)));
            fn = {'delta_gamma','nh'};
        case 2
            dplot = squeeze(mean(itpc_timefreq_dg(hiid,time_index,:)));
            fn = {'delta_gamma','hi'};
        case 3
            dplot = squeeze(mean(itpc_timefreq_g(nhid,time_index,:)));
            fn = {'gamma','nh'};
        case 4
            dplot = squeeze(mean(itpc_timefreq_g(hiid,time_index,:)));
            fn = {'gamma','hi'};
    end
    close all
    figure
    
    fig = get(groot,'CurrentFigure');
    set(fig, 'Units', 'centimeters')
    fig.Position = [3 3 4.5656 4.5656];
    
    
    imagesc(time(time_index),freq,dplot',[0.04 0.35]); axis xy;
    set(gca,'ytick',[4 10 20 30 40 50])    
    load('rdbu.mat'); colormap(cmap);
    ylabel('Frequency (Hz)'); xlabel('Time (s)')
    set(gca,'TickDir','out'); set(gca,'TickLength',[0.03, 2]);  ylim([2.5 50])
    box off; axis square; set(gca,'fontsize',8)
    cbar = colorbar('eastoutside'); 

    

    
    cd(fullfile(fileparts(which('initdir.m')),'reports','paper','fig5'))
    print(sprintf('figure-05-p%0.3i-cond-%s-group-%s.pdf',i,fn{1},fn{2}),'-dpdf','-r500')
end

end



function export_itpc_time_averages(participants_tsv,dtab)
nhid = strcmp(participants_tsv.hearing_status,'nh');
hiid = strcmp(participants_tsv.hearing_status,'hi');
cmp =  [0.7020    0.8039    0.8902; ...
        0.9843    0.7059    0.6824];
idx = 1 : 4;

for i = 1 : 2
 
    
    switch i
        case 1
            dplot = dtab.delta_gamma_itpc;
            fn = {'delta_gamma','4hz'};   
            ylab = '4 Hz ITPC';
        case 2
            dplot = dtab.gamma_itpc;
            fn = {'gamma','40hz'};  
            ylab = '40 Hz ITPC';
    end
    
    close all
    figure
    fig = get(groot,'CurrentFigure');
    set(fig, 'Units', 'centimeters')
    fig.Position = [3  3  3.4242    3.8351];
    
    hold on
    plot(idx,    mean(dplot(nhid,:)),'.','Color',cmp(1,:),'MarkerSize',8)
    plot(idx-0.1,dplot(nhid,:)','.','Color',cmp(1,:),'MarkerSize',4)
    h1 = shadedErrorBar(idx,mean(dplot(nhid,:)),std(dplot(nhid,:))/sqrt(sum(nhid)),'lineprops',{'-','Color',cmp(1,:),'MarkerFaceColor',cmp(1,:)});
    
    plot(idx,    mean(dplot(hiid,:)),'.','Color',cmp(2,:),'MarkerSize',8)
    plot(idx+0.1,dplot(hiid,:)','.','Color',cmp(2,:),'MarkerSize',4)
    h2 = shadedErrorBar(idx,mean(dplot(hiid,:)),std(dplot(hiid,:))/sqrt(sum(hiid)),'lineprops',{'-','Color',cmp(2,:),'MarkerFaceColor',cmp(2,:)});
    
    
    hleg = legend([h1.mainLine,h2.mainLine],'NH','HI');
    hleg.Box = 'off';
    
    set(gca,'xtick',idx); set(gca,'xticklabel',dtab.itpc_time_labels(1,:))
    xtickangle(40); ylabel(ylab)
    ylim([0.05 0.65]); xlim([0.6 4.4]);
    
    set(gca,'TickDir','out'); set(gca,'TickLength',[0.03, 2])
    box off; axis square; set(gca,'fontsize',8)
    
    
    
   
    
    cd(fullfile(fileparts(which('initdir.m')),'reports','paper','fig5'))    
    print(sprintf('figure-05-p%0.3i-cond-%s-itpc-%s.pdf',i+4,fn{1},fn{2}),'-dpdf','-r500')

end
end