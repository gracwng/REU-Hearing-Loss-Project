%> @file  extract_encoding_results.m
%> @brief Export panels in figure 3

%> history
%> 2019/07/08 added comments 
%> 2019/08/06 scaling and clim

function dtab = extract_encoding_results(sdir,bidsdir,pipeline_aud_attention,pipeline_eeg_attention,wa,do_plot,extrastring)

if nargin < 1 || isempty(sdir);     sdir    = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/'; end
if nargin < 2 || isempty(bidsdir);  bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end
if nargin < 3 || isempty(pipeline_aud_attention); error('specify pipeline'); end
if nargin < 4 || isempty(pipeline_eeg_attention); error('specify pipeline'); end
if nargin < 5 || isempty(wa); wa = 'woa'; end
if nargin < 6 || isempty(do_plot); do_plot = 0; end
if nargin < 7 || isempty(extrastring); extrastring = []; end
    

% import the BIDs events file which contains information about each
% participant and their hearing status (<nh> or <hi>)
participants_tsv = ioreadbidstsv(fullfile(bidsdir,'participants.tsv'));

% for the statistical analysis of the encoding accuracies we average the
% accuracies over a cluster of fronto-central electrodes. these correspond
% to the following columns in the data summaries
roi     = [4 5 6 9 10 11 39 40 41 44 45 46  38 47];

% as described in the text we estimate noise floor based on surrogate data
% across all subjects and conditions
perm_all = [];
for subid = 1 : 44
    
    % import the data from each subject
    fprintf('\n proccesing data from subject %i of %i',subid,44)
    clear dat
    fname = fullfile(sdir,'results',sprintf('sub-%0.3i_encoding_%s%s-%s-%s.mat',subid,extrastring,pipeline_aud_attention.sname,pipeline_eeg_attention.sname,wa));
    load(fname);
    
    % the encoding accuracies are here estimated as an average over
    % all 10 folds (i.e. <numel(dataout.encoding_results.vlog_st)>).
    % the number of folds is identicial for both single-talker condition
    % and two-talker condition. the encoding accuracies are stored in
    % the cellstruct as an entry with the name <acco> which in this case is
    % of size [no of electrods x 1]. <cval> and <cval_p> are temporary
    % variables for each subject
    
    cval = []; cval_p = [];
    for n =  1 : numel(dataout.encoding_results.vlog_st)
        cval(:,1,n) = dataout.encoding_results.vlog_st{n}.acco;
        cval(:,2,n) = dataout.encoding_results.vlog_att{n}.acco;
        cval(:,3,n) = dataout.encoding_results.vlog_itt{n}.acco;
        
        cval_p(:,1,n) = dataout.encoding_results.vlog_st{n}.opts.phaserand.accsurr;
        cval_p(:,2,n) = dataout.encoding_results.vlog_att{n}.opts.phaserand.accsurr;
        cval_p(:,3,n) = dataout.encoding_results.vlog_itt{n}.opts.phaserand.accsurr;
        
    end
    
    % as with the reconstruction accuracies we average over all outer
    % folds. note that the encoding accuracies obtained with surrogate data
    % (i.e. <dataout.encoding_results.vlog_st{n}.opts.phaserand.accsurr>)
    % already have been averaged over the region of interest to match the
    % actual analysis (in which we also averaged over this cluster)
    cval_p = mean(cval_p,3);
    cval = mean(cval,3);
    
    % stack the results obtained with surrogate data
    perm_all = [perm_all; cval_p(:)];
    
    % we use <acc> for the stastistical analysis and therefore average over
    % <roi>. <acc_topo> is on the other hand only used for illustrating
    % topographies of the effects and we do here not average over
    % electrodes
    acc(subid,:) = mean(cval(roi,:));
    acc_topo(subid,:,:) = cval;
end


% export the <dtab> table
dtab = table(participants_tsv.participant_id,participants_tsv.hearing_status,acc,repmat(prctile(perm_all,97.5),size(acc,1),1));
dtab.Properties.VariableNames = {'participant_id','hearing_status','encoding_accuracy','noise_floor'};

if do_plot
    export_encoding_accuracy_barplot(participants_tsv,dtab);
    export_encoding_topographies(participants_tsv,acc_topo,wa,roi);
end



end




















function export_encoding_accuracy_barplot(participants_tsv,dtab)
cmp =  [0.2235    0.5412    0.7608;...
        0.7765    0.8588    0.9373];

nhid = strcmp(participants_tsv.hearing_status,'nh');
hiid = strcmp(participants_tsv.hearing_status,'hi');


figure
myax = axes;
hold on

v   =  [0 0; ...   
        9 0; ...
        9 dtab.noise_floor(1); ...
        0 dtab.noise_floor(1)];
    
f   = [1 2 3 4];
xl  = [1 4 7];

patch('Faces',f,'Vertices',v,'FaceColor',[0.9 0.9 0.9],'FaceAlpha',1,'EdgeColor',[0.9 0.9 0.9],'EdgeAlpha',0);

h = {};
for i = 1  : 2
    
    switch i
        case 1
            dplot = dtab.encoding_accuracy(hiid,:);
        case 2
            dplot = dtab.encoding_accuracy(nhid,:);
    end
    
    h{i} = bar(xl+(i-1)*1,mean(dplot),'FaceColor',cmp(i,:));
    hold on
    h{i}.BarWidth  = 0.2;
    h{i}.EdgeColor = h{i}.FaceColor;
    
    for n = 1 : size(dplot,1)
        for c = 1 : size(dplot,2)
            if dplot(n,c)>mean(dplot(:,c))
                scatter(xl(c)+(i-1),dplot(n,c),2,'MarkerFaceColor',[0.9 0.9 0.9],'MarkerEdgeColor',[0.9 0.9 0.9],...
                    'MarkerFaceAlpha',1,'MarkerEdgeAlpha',0)
            else
                scatter(xl(c)+(i-1),dplot(n,c),2,'MarkerFaceColor',cmp(i,:)-0.1,'MarkerEdgeColor',cmp(i,:)-0.1,...
                    'MarkerFaceAlpha',1,'MarkerEdgeAlpha',0)
            end
        end
    end
    
    
    for f = 1 : 3
        hline = line([1 1]*xl(f)+(i-1)*1,[mean(dplot(:,f))-std(dplot(:,f))/sqrt(size(dplot,1))  mean(dplot(:,f))+std(dplot(:,f))/sqrt(size(dplot,1))]);
        hline.Color = 'k';
        hline.LineWidth = 1.3;
    end
end

set(gca,'xtick',xl+0.5)
set(gca,'xticklabel',{'Single-talker','Attended two-talker','Unattended two-talker'})
ylabel('Encoding accuracy');

hleg = legend([h{1} h{2}],{'HI','NH'}); hleg.Location = 'northeast';
hleg.Box = 'off'; box off
set(gca,'Fontsize',8)
ylim([0 0.25]); xlim([0 9]); xtickangle(25)
set(gca,'TickDir','out'); set(gca,'TickLength',[0.006 0.08])
myax.Layer = 'top';


fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [3 3 4.232 8.28];

hleg.Location = 'northeast';
hleg.Position(1) = hleg.Position(1)+0.1;

cd(fullfile(fileparts(which('initdir.m')),'reports','paper','fig3'))
print(sprintf('figure-03-p%0.3i.pdf',1),'-dpdf')
end







function export_encoding_topographies(participants_tsv,acc_topo,wa,highlightchannels)

nhid = strcmp(participants_tsv.hearing_status,'nh');
hiid = strcmp(participants_tsv.hearing_status,'hi');

cd(fullfile(fileparts(which('initdir.m')),'reports','paper','fig3'))
pause(0.5)

for i = 1 : 6  
    switch i
        case 1
            dplot = squeeze(mean(acc_topo(hiid,1:64,1)));
            fn = {'single_talker','hi'};
        case 2
            dplot = squeeze(mean(acc_topo(nhid,1:64,1)));
            fn = {'single_talker','nh'};
        case 3
            dplot = squeeze(mean(acc_topo(hiid,1:64,2)));
            fn = {'two_talker_attended','hi'};
        case 4
            dplot =  squeeze(mean(acc_topo(nhid,1:64,2)));
            fn = {'two_talker_attended','nh'};
        case 5
            dplot = squeeze(mean(acc_topo(hiid,1:64,3)));
            fn = {'two_talker_ignored','hi'};
        case 6
            dplot =  squeeze(mean(acc_topo(nhid,1:64,3)));
            fn = {'two_talker_ignored','nh'};
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
        'interplim', 'mask','isolines',3,'style','imsatiso','clim',[0.0 0.14]);

    layhighlight = struct;
    fnames = {'pos','width','height','label'};
    for f = 1 : length(fnames)
        layhighlight.(fnames{f}) = layout.(fnames{f})(highlightchannels,:);
    end
    ft_plot_lay(layhighlight,'box','no','label','no','point','yes','pointsymbol','o','pointcolor',[0 0 0],'pointsize',1.5,...
        'labelsize',20)
    
    load('rdbu.mat'); colormap(cmap);
    axis off; axis equal
    
    lineObj = findobj(gca, 'type', 'line');
    for l = 1:length(lineObj)
        if get(lineObj(l), 'LineWidth') > 0.5
            set(lineObj(l), 'LineWidth', 0.5);
        end
    end
    
    print(sprintf('figure-03-p%0.3i-cond-%s-group-%s.pdf',i+1,fn{1},fn{2}),'-dpdf')

    if i == 6
        fig = get(groot,'CurrentFigure');
        set(fig, 'Units', 'centimeters')
        fig.Position = [3 3 4.725 4.725];
        cb = colorbar('southoutside');
        
        set(gca,'fontsize',8)
        print('figure-03-p008-legend.pdf','-dpdf','-r500')
    end
end

end