%> @file  extract_erp.m
%> @brief Export figure showing traces of- and topographies of tone-elicited ERPs

%> history
%> 2019/07/08 added comments and doplot option
%> 2019/07/24 updated nargin

function dtab = extract_erp(sdir,bidsdir,pipeline_erp,doplot)

if nargin < 1 || isempty(sdir);     sdir    = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/'; end
% if nargin < 2 || isempty(bidsdir);  bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end

if nargin < 2 || isempty(bidsdir);  bidsdir = '/Users/student/Downloads/ds-eeg-snhl 2/ds-eeg-snhl';  % Modify this line with the new file path
end
if nargin < 4 || isempty(doplot);   doplot  = 1; end

% import the BIDs events file which contains information about each
% participant and their hearing status (<nh> or <hi>)
% participants_tsv = ioreadbidstsv(fullfile(bidsdir,'participants.tsv'));

participants_tsv = ioreadbidstsv(fullfile(bidsdir,'participants.tsv'));
% for the statistical analysis of the ERP we average the
% accuracies over a cluster of fronto-central electrodes. these correspond
% to the following columns in the data summaries
roi     = [4 5 6 9 10 11 39 40 41 44 45 46  38 47];

for subid = 1 : 44
    
    % import the data from each subject
    fprintf('\n proccesing data from subject %i of %i',subid,44)
    clear dat
    fname = fullfile(sdir,'features','eeg',sprintf('sub-%0.3i_eeg-%s.mat',subid,pipeline_erp.sname));
    load(fname);
        
    
    % take the data from all trials, and concatenate accross third
    % dimension. 
    erp_subid         = mean(cat(3,dat.trial{:}),3)';
    
    % define a corresponding time vector and ensure that each vector in the
    % cell dat.time are identical
    time = dat.time{1};
    if any(sum(ismember(cat(1,dat.time{:})',unique(time)))~=numel(unique(time)))
        error('something is wrong!')
    end
    
    % finally we export the mean amplitude of the N1 component (c.f.
    % Steve Luck's guidelines). note that we average over the fronto-central 
    % cluster of electrodes
    n1amp(subid,1)  = mean(mean(erp_subid(time>=0.075 & time<= 0.130,roi)));
    
    % for illustration purposes we also extract the traces of the erps
    erproi(:,subid) = mean(erp_subid(:,roi),2);
    
    % moreover, for illustration purposes we extract the mean N1 ampltiude
    % over all electrodes for visualizing topographies
    n1topo(subid,:)  = mean(erp_subid(time>=0.075 & time<= 0.130,:));

end

if doplot
    export_erp_figures(participants_tsv,erproi,n1amp,time,n1topo,roi)
    cd(fullfile(fileparts(which('initdir.m')),'reports','paper','additional'))
    print('figure-erp.png','-dpng','-r500')
end


% export <dtab> table
dtab = table(participants_tsv.participant_id,participants_tsv.hearing_status,n1amp);
dtab.Properties.VariableNames = {'participant_id','hearing_status','erp_n1'};



end










function export_erp_figures(participants_tsv,erproi,n1amp,time,n1topo,highlightchannels)
nhid = strcmp(participants_tsv.hearing_status,'nh');
hiid = strcmp(participants_tsv.hearing_status,'hi');

cmp =   [0.9059    0.8824    0.9373; ...
    0.4353         0    0.1490];


figure('Position',[-100 -100 600 250]);
for i = 1 : 2
    subplot(2,4,[i i+4])
    hold on
    switch i
        case 1
            erp_trace = erproi(:,nhid);
            tid = {'ERP NH'};
        case 2
            erp_trace = erproi(:,hiid);
            tid = {'ERP HI'};
    end
    
    plot(time*1000,erp_trace,'-','Color',cmp(1,:))
    plot(time*1000,mean(erp_trace,2),'-','Color',cmp(2,:),'LineWidth',2.5)
    h = line([time(1) time(end)]*1000,[0 0]);
    h.Color = 'k';
    h.LineWidth = 1;
    xlim([-100 400]); ylim([-12 12])
    xlabel('Time (ms)'); ylabel('Amplitude (\muv)')
    title(tid,'Fontweight','normal')
    set(gca,'Fontsize',8); box off
    
    plot([0.075 0.130]*1000,[1 1]*-12,'-k','LineWidth',4)

end


cmap_bar = [0.8706    0.7961    0.8941; ...
    0.9490    0.8118    0.7725];
subplot(2,4,[3 3+4])
for i = 1 : 2
    hold on
    switch i
        case 1
            n1 = mean(n1amp(nhid),1);
            n1std = std(n1amp(nhid));
            nobs = numel(n1amp(nhid));
            
        case 2
            n1 = mean(n1amp(hiid),1);
            n1std = std(n1amp(hiid));
            nobs = numel(n1amp(hiid));
    end
    
    h(i) = bar(i,n1);
    set(h(i),'FaceColor',cmap_bar(i,:))
    errorbar(i,n1,n1std/sqrt(nobs),'.k')
end

ylabel('Mean amplitude'); box on
set(gca,'xtick',[1 2])
set(gca,'xticklabel',{'NH','HI'})
title({'N1 amplitude'},'Fontweight','normal')
set(gca,'Fontsize',8);


for i = 1 : 2
    switch i
        
        case 1
            dplot = mean(n1topo(nhid,:));
            dtit = {'N1 (NH)'};
        case 2
            dplot = mean(n1topo(hiid,:));
            dtit = {'N1 (HI)'};
    end
    
    subplot(2,4,4+(i-1)*4)
    
    load('rdbu.mat'); colormap(cmap);
    cfg=[];
    cfg.layout='biosemi64.lay';
    layout=ft_prepare_layout(cfg);
    
    ft_plot_topo(layout.pos(1:numel(dplot),1), layout.pos(1:numel(dplot),2), dplot',...
        'mask', layout.mask,...
        'outline', layout.outline, ...
        'interplim', 'mask','isolines',3,'style','imsatiso','clim',[-5 5]);
    
    layhighlight = struct;
    fnames = {'pos','width','height','label'};
    for f = 1 : length(fnames)
        layhighlight.(fnames{f}) = layout.(fnames{f})(highlightchannels,:);
    end
    ft_plot_lay(layhighlight,'box','no','label','no','point','yes','pointsymbol','.','pointcolor',[0 0 0],'pointsize',4,...
        'labelsize',8)
    
    
    lineObj = findobj(gca, 'type', 'line');
    for l = 1:length(lineObj)
        if get(lineObj(l), 'LineWidth') > 0.5
            set(lineObj(l), 'LineWidth', 0.5);
        end
    end
    
    axis off
    axis equal
    
    load('rdbu.mat')
    colormap(cmap);
    
    cb = colorbar
    cb.Label.String = 'uV';
    title(dtit,'FontWeight','Normal');
    
    set(gca,'fontsize',8)
end


fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [1.6933 7.2231 21.9869 7.5142];

end
