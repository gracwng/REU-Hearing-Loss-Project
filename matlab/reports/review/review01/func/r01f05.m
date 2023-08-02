%> @file r01f05.m
%> @brief Some of the subjects that were here considered to be 
%> normal-hearing subjects had audiograms that exceeded 20 dB HL. This
%> function exports figures with data from a subset of the listeners who
%> have a more strict criterion for what is considered to be normal-hearing.
%> Specifically, we focus on NH listeners that have audiograms <= 20 dB HL
%> at all of the audiometric frequencies and both ears. 
%> This results in 10 listeners with an age range from 53 to 69 years old.
%> To make our group comparison more fair, we then similarly extract all HI
%> listeners that are <= 69 years old. This results in 11 HI listeners that
%> are matched in age with the NH subset.
%> @param sdir directory which contains derived data
%> @param bidsdir directory which contains source data
%> @pipeline_dg_itpc a struct that matches what was defined in
%> "workflows_paper.m"
%> @doplot a flag (0/1) indicating if the figure should be exported
%> (default = 1)

function index_subgroup = r01f05(bidsdir,savefigures)

if nargin < 1 || isempty(bidsdir); bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end
if nargin < 2 || isempty(savefigures); savefigures = 1; end


% we first import the tsv file that contains information about each of the
% participants. this is done to extract the audiograms for each of the
% subjects
dat = ioreadbidstsv(fullfile(bidsdir,'participants.tsv'));


% the following lines are used to extract the audiograms and import them to a
% 3d array (subject x frequency x ear)
f            = [125,250,500,1000,2000,3000,4000,6000,8000];
agram         = [];
for n = 1 : numel(f)
    agram(:,n,1) = dat.(['audiogram_left_ear_',num2str(f(n)),'Hz']);
    agram(:,n,2) = dat.(['audiogram_right_ear_',num2str(f(n)),'Hz']);
end

% the <data_summary> table contains data summaries used for plotting. we
% import this table
load('data_summary.mat')

% which of the subjects have audiograms that fulfil dB HL <= 20 dB?
id_subgroup_nh = find(sum(sum(agram>20,2),3)==0);


% to make group comparisons more balanced, we here illustrate the effects
% for a subset of the hearing-impaired listeners that have a maximal
% allowed age similar to that for the NH subgroup. this should make the
% groups more balanced in size
max_age_group  = max(dtab([id_subgroup_nh],:).age);

id_hi = find(strcmp(dtab.hearing_status,'hi'));

id_subgroup_hi = id_hi(find(dtab(id_hi,:).age<=max_age_group));

index_subgroup = [id_subgroup_nh; id_subgroup_hi];

dtab_subgroup = dtab(index_subgroup,:);

if savefigures
export_audiograms(dtab_subgroup)
export_encoding_accuracy_barplot(dtab_subgroup)
export_reconstruction_accuracy_barplot(dtab_subgroup)
export_itpc_time_averages(dtab_subgroup)
export_classification_figure(dtab_subgroup)
export_attention_scores(dtab_subgroup)
export_age_distribution(dtab_subgroup)
export_psychophysics(dtab_subgroup)
end
end





function export_encoding_accuracy_barplot(dtab)
cmp =  [0.2235    0.5412    0.7608;...
    0.7765    0.8588    0.9373];

nhid = strcmp(dtab.hearing_status,'nh');
hiid = strcmp(dtab.hearing_status,'hi');


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


cd(fullfile(fileparts(which('initdir.m'))))
print(fullfile(pwd,'reports','review','review01','fig05','r0105_encoding.pdf'),'-dpdf','-r0')


end


function export_age_distribution(dtab)

dtab.hearing_status(strcmp(dtab.hearing_status,'nh'))=repmat({'NH'},sum(strcmp(dtab.hearing_status,'nh')),1);
dtab.hearing_status(strcmp(dtab.hearing_status,'hi'))=repmat({'HI'},sum(strcmp(dtab.hearing_status,'hi')),1);

figure
fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [11.3782 7.0239 6.2982 7.7496];

boxplot(dtab.age,dtab.hearing_status,'Color',[0.8 0.8 0.8]-0.4)
title('Sub-group','FontWeight','Normal')
hold on
load rdbu
cmap = cmap(round(linspace(1,size(cmap,1),size(dtab,1))),:);
h = [];
for i = 1 : size(dtab,1)
    if strcmp(dtab.hearing_status(i),'NH')==1
        hl(i)=plot(1+(rand(1)-0.5)*0.2,dtab.age(i),'sq','MarkerFaceColor',cmap(i,:),'MarkerEdgeColor',[1 1 1]*0.8);
    else
        hl(i)=plot(2+(rand(1)-0.5)*0.2,dtab.age(i),'o','MarkerFaceColor',cmap(i,:),'MarkerEdgeColor',[1 1 1]*0.8);
        
    end
end
ylabel('Age')
hleg = legend(hl,dtab.participant_id);
hleg.Location = 'eastoutside';
hleg.FontSize = 6;
set(gca,'Fontsize',8)
hleg.Box = 'off';


cd(fullfile(fileparts(which('initdir.m'))))
print(fullfile(pwd,'reports','review','review01','fig05','r0105_age.pdf'),'-dpdf')

end



function export_itpc_time_averages(dtab)
nhid = strcmp(dtab.hearing_status,'nh');
hiid = strcmp(dtab.hearing_status,'hi');
cmp =  [0.7020    0.8039    0.8902; ...
    0.9843    0.7059    0.6824];
idx = 1 : 4;

close all
figure
fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [3  3  3.4242    3.8351];
fig.Position = [3 3 4.232 8.28];
for i = 1 : 2
    subplot(2,1,i)
    
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
    
    
    
    hold on
    plot(idx,    mean(dplot(nhid,:)),'.','Color',cmp(1,:),'MarkerSize',8)
    plot(idx-0.1,dplot(nhid,:)','.','Color',cmp(1,:),'MarkerSize',4)
    h1 = shadedErrorBar(idx,mean(dplot(nhid,:)),std(dplot(nhid,:))/sqrt(sum(nhid)),'lineprops',{'-','Color',cmp(1,:),'MarkerFaceColor',cmp(2,:)});
    
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
    
    
    
    
    
    
end

cd(fullfile(fileparts(which('initdir.m'))))
print(fullfile(pwd,'reports','review','review01','fig05','r0105_itpc.pdf'),'-dpdf')

end




function export_audiograms(ds)

Frequencies={'.125' '.25' '.5' '1' '2' '3' '4' '6' '8'};

figure;
fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [3 3 3.1 4.6*2];
for gr = 1 : 2
    subplot(2,1,gr)
    switch gr
        case 1
            dplot = ds.agram(strcmp(ds.hearing_status,'nh'),:);
        case 2
            dplot = ds.agram(strcmp(ds.hearing_status,'hi'),:);
    end
    
    
    
    plot(dplot','color',[0.8 0.8 0.8]);
    hold on
    plot(mean(dplot,1),'color','k','linewidth',2);
    set(gca,'Ydir','reverse','xtick',1:length(Frequencies),'xticklabel',Frequencies);
    ylabel('Hearing level (dB)')
    xl = xlabel('Frequency (kHz)')
    ax = gca;
    ylim([-10 110])
    xlim([1 9])
    xtickangle(50)
    set(gca,'Fontsize',8);
    box off
    
    if gr == 1
        hline = line([0 size(dplot,2)],[20 20]);
        hline.LineStyle = '--';
        hline.Color = [0.5 0.5 0.5];
    end
    
end


cd(fullfile(fileparts(which('initdir.m'))))
print(fullfile(pwd,'reports','review','review01','fig05','r0105_agram.pdf'),'-dpdf')

end




function export_reconstruction_accuracy_barplot(dtab)
figure
myax = axes;

hold on

cmp = [0.4157 0.4157  0.4157;...
    0.8510  0.8510  0.8510];

nhid = strcmp(dtab.hearing_status,'nh');
hiid = strcmp(dtab.hearing_status,'hi');


v   = [0 0; ...
    9 0; ...
    9 dtab.reconstruction_noise_floor(1); ...
    0 dtab.reconstruction_noise_floor(1)];
f   = [1 2 3 4];
xl  = [1 4 7];

patch('Faces',f,'Vertices',v,'FaceColor',[0.9 0.9 0.9],'FaceAlpha',1,'EdgeColor',[0.9 0.9 0.9],'EdgeAlpha',0);
plot([0 9],[1 1]*dtab.reconstruction_noise_floor(1),'--k')

h = {};
for i = 1  : 2
    
    switch i
        case 1
            dplot = dtab.reconstruction_accuracy(hiid,:);
        case 2
            dplot = dtab.reconstruction_accuracy(nhid,:);
    end
    
    h{i} = bar(xl+(i-1)*1,mean(dplot),'FaceColor',cmp(i,:));
    hold on
    h{i}.BarWidth = 0.2;
    h{i}.EdgeColor =h{i}.FaceColor;
    
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
ylabel({'Reconstruction accuracy'})
hleg = legend([h{1} h{2}],{'HI','NH'});
hleg.Location = 'northwest'; %odd behavior?
hleg.Box = 'off';
box off; ylim([0 0.45]);
set(gca,'Fontsize',8)
xtickangle(25); xlim([0 9])
set(gca,'TickDir','out');
set(gca,'TickLength',[0.006  0.08])

myax.Layer = 'top';

fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [3 3 4.232 8.28];

cd(fullfile(fileparts(which('initdir.m'))))
print(fullfile(pwd,'reports','review','review01','fig05','r0105_reconstructionaccuracy.pdf'),'-dpdf')


end






function export_classification_figure(dtab)

dtab.hearing_status(strcmp(dtab.hearing_status,'nh'))=repmat({'NH'},sum(strcmp(dtab.hearing_status,'nh')),1);
dtab.hearing_status(strcmp(dtab.hearing_status,'hi'))=repmat({'HI'},sum(strcmp(dtab.hearing_status,'hi')),1);

cmap = [0.4 0.4 0.4; 0.8 0.8 0.8];
rng('default')

figure
fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [3 3 3 5.4];

clear g
g(1,1)=gramm('x',dtab.hearing_status,'y',dtab.classification_accuracy*100,'color',dtab.hearing_status);
g(1,1).set_names('x','     ','y','Classification accuracy','color','');
g(1,1).stat_summary('geom',{'bar'},'dodge',0);
g(1,1).geom_jitter('width',0.1,'height',0,'dodge',0.0);
g(1,1).stat_summary('geom',{'black_errorbar'},'dodge',0,'type','sem');
g(1,1).set_point_options('base_size',2);
g(1,1).no_legend();
g(1,1).set_color_options('map',cmap);
g(1,1).axe_property('fontsize',8,'fontweight','Normal')
g(1,1).axe_property('YLim',[50 100]);
g.draw()

point_color = [0.5 0.5 0.5];
set([g(1,1).results.geom_jitter_handle],'Color',point_color);
set([g(1,1).results.geom_jitter_handle],'MarkerFaceColor',point_color);
set([g(1,1).results.geom_jitter_handle],'MarkerEdgeColor',point_color);
set([g(1,1).results.stat_summary.errorbar_handle],'LineWidth',1);
XdataA=g(1,1).results.stat_summary(2).errorbar_handle.XData;
XdataB=g(1,1).results.stat_summary(1).errorbar_handle.XData;

XdataB=g(1,1).results.stat_summary(2).errorbar_handle.XData;
set([g(1,1).results.stat_summary(2).errorbar_handle],'Xdata',XdataA);
set([g(1,1).results.stat_summary(1).errorbar_handle],'Xdata',XdataA-1);
set([g(1,1).results.geom_jitter_handle(1)],'MarkerSize',1);
set([g(1,1).results.geom_jitter_handle(2)],'MarkerSize',1);


cd(fullfile(fileparts(which('initdir.m'))))
print(fullfile(pwd,'reports','review','review01','fig05','r0105_classificationaccuracy.pdf'),'-dpdf')


end





% the below functions are used to export panels in figure 2 respectively
% figure 1. <export_psychophysics> uses gramm to export figure 2 panels.
% <export_audiograms> exports difficulty ratings and average scores. note
% that <export_audiograms> exports a legend separately
function export_attention_scores(ds)

cmap = [0.4 0.4 0.4; 0.8 0.8 0.8];

fig = figure;
set(fig, 'Units', 'centimeters')
fig.Position = [3.4925 3.4925 5.8 4.8];

nsubjects = [sum(strcmp(ds.hearing_status,'nh')) sum(strcmp(ds.hearing_status,'hi'))];
idnh  = find(strcmp(ds.hearing_status,'nh'));
idhi  = find(strcmp(ds.hearing_status,'hi'));

for gr = 1 : 2
    switch gr
        case 1
            dplot = ds.ratingST;
             
            dplot_st_mu = [mean(dplot(idnh,1)) mean(dplot(idhi,1))];
            dplot_st_std = [std(dplot(idnh,1)) std(dplot(idhi,1))]./sqrt(nsubjects);
                
            dplot = ds.ratingTT;
             
            dplot_tt_mu = [mean(dplot(idnh,1)) mean(dplot(idhi,1))];
            dplot_tt_std = [std(dplot(idnh,1)) std(dplot(idhi,1))]./sqrt(nsubjects);
            
            
            ylab     = 'Difficulty rating';
            yl       = [0 100];
        case 2
              dplot = ds.scoreST;
             
            dplot_st_mu = [mean(dplot(idnh,1)) mean(dplot(idhi,1))];
            dplot_st_std = [std(dplot(idnh,1)) std(dplot(idhi,1))]./sqrt(nsubjects);
                
            dplot = ds.scoreTT;
             
            dplot_tt_mu = [mean(dplot(idnh,1)) mean(dplot(idhi,1))];
            dplot_tt_std = [std(dplot(idnh,1)) std(dplot(idhi,1))]./sqrt(nsubjects);
            
            
            
            
            
            ylab     = 'Percent correct (%)';
            yl       = [70 100];
    end
    
    
    subplot(1,2,gr)
    
    h1 = errorbar(dplot_st_mu,dplot_st_std,'Color',cmap(1,:),'LineWidth',1)
    hold on
    h2 = errorbar(dplot_tt_mu,dplot_tt_std,'Color',cmap(2,:),'LineWidth',1)
    
    if gr == 2
 hleg = legend({'Single-talker','Two-talker'});
hleg.Box = 'on';
hleg.Location = 'southwest';
hleg.FontSize = 8;
    end

    xlim([0.5 2.5]); ylim(yl); ylabel(ylab);
    set(gca,'xtick',1:2); set(gca,'xticklabel',{'NH','HI'})
    set(gca,'Fontsize',8); set(gca,'TickDir','out');
    set(gca,'TickLength',[0.009, 0.6])
    box off
    
end



cd(fullfile(fileparts(which('initdir.m'))))
print(fullfile(pwd,'reports','review','review01','fig05','r0105_attentionbehavior.pdf'),'-dpdf')

end






function export_psychophysics(ds)

varoi   = {'SRT','SSQall','FTtemporal','digitspanB'};
ylab    = {'SRT','SSQ rating (1-10)','Temporal RoM (dB)','Digitspan score (B)'};
titles  = {{'Speech-in-noise','processing'},{'Self assesed','hearing ability'},{'Temporal','processing'},{'Cognitive','abilities'}};

ds.hearing_status(strcmp(ds.hearing_status,'nh')) = repmat({'NH'},sum(strcmp(ds.hearing_status,'nh')),1);
ds.hearing_status(strcmp(ds.hearing_status,'hi')) = repmat({'HI'},sum(strcmp(ds.hearing_status,'hi')),1);

fsize = 8;
sw = 0.3;
shift=linspace(0.5,0.8,6);
shift = [shift 1 ];

    figure
    fig = get(groot,'CurrentFigure');
    set(fig, 'Units', 'centimeters')
    fig.Position = [3 3 3.6*2 3*2];
        clear g

for tt =1 : length(varoi)
    cmap = [shift(tt) shift(tt) shift(tt);shift(tt) shift(tt) shift(tt)];
    

    
    si = (tt>2)+1;
    sj = ~mod(tt,2)+1;
    
    g(si,sj)=gramm('x',ds.hearing_status,'y',ds.(varoi{tt}),'color',ds.hearing_status);
    g(si,sj).set_names('x','','y',ylab{tt},'color','');
    g(si,sj).stat_boxplot('width',sw)
    g(si,sj).no_legend();
    g(si,sj).set_color_options('map',cmap);
    g(si,sj).axe_property('fontsize',fsize,'fontweight','Normal')
    g.coord_flip();
    
    g.draw()
    
    set([g(si,sj).results.stat_boxplot.outliers_handle],'MarkerSize',2)
    set([g(si,sj).results.stat_boxplot.outliers_handle],'MarkerEdgeColor','k')
    
    end


cd(fullfile(fileparts(which('initdir.m'))))
print(fullfile(pwd,'reports','review','review01','fig05','r0105_psychophysics.pdf'),'-dpdf')


end


