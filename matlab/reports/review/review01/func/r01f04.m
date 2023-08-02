%> @file r01f04.m
%> @brief For illustrative purposes, we here plot 4 Hz ITPC and 40 Hz ITPC 
%> across EEG responses to EFR stimuli, but averaged over EEG electrodes 
%> from each hemisphere. In the topographies, crosses show defined "left
%> hemisphere electrodes", squares show "right hemisphere electrodes". 
%> The right panel shows group-mean ITPC in short time windows
%> @param sdir directory which contains derived data
%> @param bidsdir directory which contains source data
%> @pipeline_dg_itpc a struct that matches what was defined in
%> "workflows_paper.m"
%> @doplot a flag (0/1) indicating if the figure should be exported
%> (default = 1)

function dtab_itpc_hemisphere = r01f04(sdir,bidsdir,pipeline_dg_itpc,doplot)

if nargin < 1 || isempty(sdir);     sdir    = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/'; end
if nargin < 2 || isempty(bidsdir);  bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end
if nargin < 3 || isempty(pipeline_dg_itpc)
    pipeline_dg_itpc = struct;
    pipeline_dg_itpc.task = 'tonestimuli';
    pipeline_dg_itpc.sname = 'wf_dg_itpc';
end
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
    
    % we now extract data from the two hemispheres
    labels = itpc_dg(1).label;
    [right_hemisphere,left_hemisphere] = label2hemisphere(labels);
    
    
    % check that everything is in order before exporting the results. the
    % entries <freq>, <time> and <label> should be identical for the two
    % experimental conditions
    freq_dg = cat(1,itpc_dg.freq);
    freq_g = cat(1,itpc_g.freq);
    
    time_dg = cat(1,itpc_dg.time);
    time_g = cat(1,itpc_g.time);
    
    label_dg = cat(2,itpc_dg.label);
    label_g = cat(2,itpc_g.label);
    
    
    if subid == 1
        ref_freq = freq_dg;
        ref_label = label_dg(:,1);
        ref_time = time_dg(1,:);
    end
    
    if abs(sum(freq_dg-ref_freq))~=0 | abs(sum(time_dg-time_g))~=0
        error('something went wrong!')
    end
    
    if abs(sum(time_dg(1,:)-ref_time))~=0
        error('something went wrong!')
    end
    
    
    if any(ismember(label_dg,ref_label)==0)
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
        
        
        itpc_4_hz_dg(subid,ti,1)  = mean(mean(itpc_dg(left_hemisphere,time_index,i4hz)));
        itpc_40_hz_g(subid,ti,1)  = mean(mean(itpc_g(left_hemisphere,time_index,i40hz)));
        
        itpc_4_hz_dg(subid,ti,2)  = mean(mean(itpc_dg(right_hemisphere,time_index,i4hz)));
        itpc_40_hz_g(subid,ti,2)  = mean(mean(itpc_g(right_hemisphere,time_index,i40hz)));
        
        % additionally, we also prepare ticks for figures
        xticks{subid,ti} = sprintf('%0.1fs-%0.1fs',time(time_index(1)),time(time_index(end)));
    end
    
    % for the topographical depictions we average everything over 0-2 s
    % (including endpoints). this is done for the 4 Hz
    % ITPC for delta-gamma data and 40 Hz ITPC for gamma data
    itpc_topo_dg(subid,:) = mean(mean(itpc_dg(:,time>=0 & time <= 2,i4hz),2),3);
    itpc_topo_g(subid,:)  = mean(mean(itpc_g(:,time>=0 & time <= 2,i40hz),2),3);
    
    
    
end

dtab_itpc_hemisphere = table(itpc_4_hz_dg(:,:,1),itpc_4_hz_dg(:,:,2),itpc_40_hz_g(:,:,1),itpc_40_hz_g(:,:,2));
dtab_itpc_hemisphere.Properties.VariableNames = {'ITPC_4_HZ_DG_LEFT','ITPC_4_HZ_DG_RIGHT','ITPC_40_HZ_G_LEFT','ITPC_40_HZ_G_RIGHT'};
if doplot
figure
nhid = strcmp(participants_tsv.hearing_status,'nh');
hiid = strcmp(participants_tsv.hearing_status,'hi');

for i = 1 : 4
    switch i
        case 1
            dplot = mean(itpc_topo_dg(hiid,:),1);
            tit = 'HI, 4 hz';
            subplot(4,4,5)
        case 2
            dplot = mean(itpc_topo_dg(nhid,:),1);
            tit = 'NH, 4 hz';
            subplot(4,4,9)
        case 3
            dplot = mean(itpc_topo_g(hiid,:),1);
            tit = 'HI, 40 hz';
            subplot(4,4,6)
        case 4
            dplot = mean(itpc_topo_g(nhid,:),1);
            tit = 'NH, 40 hz';
            subplot(4,4,10)
    end
    plot_topographies(dplot,left_hemisphere,right_hemisphere,[0.04 0.35])
    title(tit,'FontWeight','Normal','Fontsize',8)
end



% figure
plot_hemisphere_time(itpc_4_hz_dg,itpc_40_hz_g,participants_tsv,xticks)
fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [3  3  1.2*23.1192   1.2*17.7541];

cd(fullfile(fileparts(which('initdir.m'))))
print(fullfile(pwd,'reports','review','review01','fig04','r0104.pdf'),'-dpdf','-r0')
end
end






function [right_hemisphere,left_hemisphere] = label2hemisphere(labels)
% extract all of the Biosemi labels that corresponds to the left/right
% hemisphere. we do not focus on the midline (e.g. Cz, Pz etc)
lr = [];
for ch = 1 : numel(labels)
    
    if isempty(regexp(labels{ch},'\d'))
        lr(ch) = nan;
    else
        lr(ch) = str2num(labels{ch}(regexp(labels{ch},'\d')));
    end
end
right_hemisphere = mod(lr,2)==0;
left_hemisphere = mod(lr,2)==1;

end


function plot_topographies(dplot,left_hemisphere,right_hemisphere,clim)



load('rdbu.mat'); colormap(cmap);

cfg=[];
cfg.layout='biosemi64.lay';
layout=ft_prepare_layout(cfg);

ft_plot_topo(layout.pos(1:numel(dplot),1), layout.pos(1:numel(dplot),2), dplot',...
    'mask', layout.mask,...
    'outline', layout.outline, ...
    'interplim', 'mask','isolines',3,'style','imsatiso','clim',clim);



layhighlight_left = struct;
fnames = {'pos','width','height','label'};
for f = 1 : length(fnames)
    layhighlight_left.(fnames{f}) = layout.(fnames{f})(left_hemisphere,:);
end
ft_plot_lay(layhighlight_left,'box','no','label','no','point','yes','pointsymbol','x','pointcolor',[0 0 0],'pointsize',4,...
    'labelsize',20)


layhighlight_right = struct;
fnames = {'pos','width','height','label'};
for f = 1 : length(fnames)
    layhighlight_right.(fnames{f}) = layout.(fnames{f})(right_hemisphere,:);
end
ft_plot_lay(layhighlight_right,'box','no','label','no','point','yes','pointsymbol','sq','pointcolor',[0 0 0],'pointsize',4,...
    'labelsize',20)




load('rdbu.mat'); colormap(cmap);
axis off; axis equal

lineObj = findobj(gca, 'type', 'line');
for l = 1:length(lineObj)
    if get(lineObj(l), 'LineWidth') > 0.5
        set(lineObj(l), 'LineWidth', 0.5);
    end
end
end




function plot_hemisphere_time(itpc_4_hz_dg,itpc_40_hz_g,participants_tsv,xticks)


nhid = strcmp(participants_tsv.hearing_status,'nh');
hiid = strcmp(participants_tsv.hearing_status,'hi');




for sb = 1 : 2
    if sb == 1
        subplot(4,4,[3 4 7 8])
    else
        subplot(4,4,[11 12 15 16])
        
    end
    load rdbu
    cmp = cmap([40; 10; 100; 120],:);
    lstyle = {'-','--','-','--'};
    for i = 1 : 4
        clear dplot
        if sb == 1
            switch i
                case 1
                    dplot = squeeze(itpc_4_hz_dg(nhid,:,1));
                case 2
                    dplot = squeeze(itpc_4_hz_dg(nhid,:,2));
                case 3
                    dplot = squeeze(itpc_4_hz_dg(hiid,:,1));
                case 4
                    dplot = squeeze(itpc_4_hz_dg(hiid,:,2));
            end
        elseif sb == 2
            
            switch i
                case 1
                    dplot = squeeze(itpc_40_hz_g(nhid,:,1));
                case 2
                    dplot = squeeze(itpc_40_hz_g(nhid,:,2));
                case 3
                    dplot = squeeze(itpc_40_hz_g(hiid,:,1));
                case 4
                    dplot = squeeze(itpc_40_hz_g(hiid,:,2));
            end
            
        end
        errorbar((1:4)+0.08-i*0.04,mean(dplot),std(dplot)/sqrt(size(dplot,1)),...
            lstyle{i},'Color',cmp(i,:),'LineWidth',2)
        hold on
        
    end
    
    set(gca,'xtick',(1:4)); set(gca,'xticklabel',xticks(1,:))
    xtickangle(40);
    ylim([0.05 0.65]); xlim([0.6 4.4]);
    set(gca,'TickDir','out'); set(gca,'TickLength',[0.03, 2])
    box off; axis square; set(gca,'fontsize',8)
    
    hleg = legend('NH (left hemisphere)','NH (right hemisphere)','HI (left hemisphere)','HI (right hemisphere)');
    hleg.Box = 'off';
    ylabel('ITPC')
    if sb == 1
        ylabel('4 Hz ITPC');
    elseif sb == 2
        ylabel('40 Hz ITPC');
        xlabel('Time (s)')
    end
    
end

end