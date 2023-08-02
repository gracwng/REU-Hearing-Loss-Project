%> @file  extract_behavior.m
%> @brief Export panels in figure 1 and 2

%> history
%> 2019/07/08 added comments and included a do-plot input
%> 2019/07/15 made code more readable
%> 2019/07/17 comments and made behavior figure wider. updated field codes
%such that importing events files comply with new BIDs format
%> 2019/07/22 speech_reception_tresholds replaced with
%speech_reception_thresholds and BIDs data updated accordingly

function ds = extract_behavior(sdir,bidsdir,doplot)

if nargin < 1 || isempty(sdir);     sdir    = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/'; end
if nargin < 2 || isempty(bidsdir);  bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end
if nargin < 3 || isempty(doplot);   doplot  = 1; end

dat = ioreadbidstsv(fullfile(bidsdir,'participants.tsv'));

ds            = dat(:,1:3);
ds.SRT        = dat.speech_reception_thresholds;
ds.SSQall     = mean([dat.SSQ_qual dat.SSQ_spatial dat.SSQ_speech],2);
ds.FTtemporal = dat.FT_test_temporal;
ds.FTspectral = dat.FT_test_spectral;
ds.digitspanB = dat.digit_span_backward;
ds.digitspanF = dat.digit_span_forward;

f             = [125,250,500,1000,2000,3000,4000,6000,8000];
ds.agram_f    = repmat(f,size(ds,1),1);


agram         = [];
for n = 1 : numel(f)
    agram(:,n,1) = dat.(['audiogram_left_ear_',num2str(f(n)),'Hz']);
    agram(:,n,2) = dat.(['audiogram_right_ear_',num2str(f(n)),'Hz']);
end


% Is absolute difference in pure-tone average 
% (PTA; measured at 500 Hz, 1000 Hz, 2000 Hz and 4000 Hz) between ears 
% less than or equal to 15 dB HL? if not, then stop execution!
if any(abs(diff(squeeze(mean(agram(:,ismember(f,[500 1000 2000 4000]),:),2)),[],2))>15)
    error('the absolute difference in PTA between ears exceed 15 dB HL')
end

% we'll now instead focus on the mean across ears. keep in mind that the
% spatial location of the target speaker was randomized and balanced within
% subject in the selective auditory attention experiment 
ds.agram     = mean(agram,3);



ratingST = []; ratingTT = []; scoreST = []; scoreTT = []; missing_trials = [];
for i = 1 : size(dat,1)
    
    [ratingST(i,1), ratingTT(i,1), scoreST(i,1), scoreTT(i,1)] = extract_avg_ratings_and_scores(i,[],bidsdir,ds);
    [ratingST(i,2), ratingTT(i,2), scoreST(i,2), scoreTT(i,2)] = extract_avg_ratings_and_scores(i,'attendmale',bidsdir,ds);
    [ratingST(i,3), ratingTT(i,3), scoreST(i,3), scoreTT(i,3)] = extract_avg_ratings_and_scores(i,'attendfemale',bidsdir,ds);
    
   
end

ds.ratingST = ratingST;
ds.ratingTT = ratingTT;
ds.scoreST  = scoreST;
ds.scoreTT  = scoreTT;

if doplot
% export the figures. all of the figures will be stored in a path relative
% to <initdir.m> (specifically, >reports>paper>fig1 and
% >reports>paper>fig2)
export_attention_scores(ds)
export_audiograms(ds)
export_psychophysics(ds)
end
end







function [r_st, r_tt, s_st, s_tt] = extract_avg_ratings_and_scores(subid,type,bidsdir,ds)
% this function is used to extract average ratings and average speech
% comprehension scores. we first import the BIDs events, then we use
% <split_events_single_talker_two_talker> to extract <singletalker> and
% <twotalker> ratings/scores and subsequently find all offset triggers
% (i.e., events.value == 131) and take the mean over these entries
cd(fullfile(bidsdir,ds.participant_id{subid},'eeg'))

events = ioreadbidstsv(sprintf('%s_task-selectiveattention_events.tsv',ds.participant_id{subid}));

[events_st, events_tt] = split_events_single_talker_two_talker(events);


% as an additional control we also extract all events that belong to
% <attendmale> and <attendfemale> triggers. 
if strcmp(type,'attendmale')
    events_st = events_st(find(strcmp(events_st.attend_male_female,'attendmale'))+1,:);
    events_tt = events_tt(find(strcmp(events_tt.attend_male_female,'attendmale'))+1,:);
end

if strcmp(type,'attendfemale')
    events_st = events_st(find(strcmp(events_st.attend_male_female,'attendfemale'))+1,:);
    events_tt = events_tt(find(strcmp(events_tt.attend_male_female,'attendfemale'))+1,:);
end

% export the raw ratings (<r_st> and <r_tt>) and scores (<s_st> and
% <s_tt>). we do not average yet as we would like to concatenate data from
% two session for sub024
[r_st, s_st] = extract_ratings_and_scores(events_st);
[r_tt, s_tt] = extract_ratings_and_scores(events_tt);



if subid == 24
    % do exactly the same as before, and subsequently concatenate data from
    % the two sessions
    cd(fullfile(bidsdir,ds.participant_id{subid},'eeg'))
    clear events events_st events_tt
    events = ioreadbidstsv(sprintf('%s_task-selectiveattention_run-2_events.tsv',ds.participant_id{subid}));
    
    [events_st, events_tt] = split_events_single_talker_two_talker(events);
    
    if strcmp(type,'attendmale')
        events_st = events_st(find(strcmp(events_st.attend_male_female,'attendmale'))+1,:);
        events_tt = events_tt(find(strcmp(events_tt.attend_male_female,'attendmale'))+1,:);
    end
    
    if strcmp(type,'attendfemale')
        events_st = events_st(find(strcmp(events_st.attend_male_female,'attendfemale'))+1,:);
        events_tt = events_tt(find(strcmp(events_tt.attend_male_female,'attendfemale'))+1,:);
    end
    
    
    [r_st_2, s_st_2] = extract_ratings_and_scores(events_st);
    [r_tt_2, s_tt_2] = extract_ratings_and_scores(events_tt);
    
    r_st = [r_st; r_st_2];
    r_tt = [r_tt; r_tt_2];
    s_st = [s_st; s_st_2];
    s_tt = [s_tt; s_tt_2];
    
    
end

% finally, we extract the average ratings
r_st = mean(r_st);
r_tt = mean(r_tt);
s_st = mean(s_st);
s_tt = mean(s_tt);

end

function [events_st, events_tt] = split_events_single_talker_two_talker(events)
% take a BIDs events table and extract only the rows with events that
% correspond to single-talker trials and two-talker trials. due to the way
% the BIDs file is organized, we find the onset triggers labelled as
% <singletalker> or <twotalker> and then take the corresponding offset
% trigger indices (so for <singletalker> rows and for <twotalker> rows 
% we include both onset and offset triggers). Keep in mind that <twotalker> 
% additionally contain a masker trigger and therefore we  
idst = find(strcmp(events.single_talker_two_talker,'singletalker'));
idtt = find(strcmp(events.single_talker_two_talker,'twotalker'));

events_st = events(sort([idst; idst+1]),:);
events_tt = events(sort([idtt; idtt+2]),:);

end


function [rating, qscore] = extract_ratings_and_scores(events)
% use this function to extract offset events and extract average ratings
% and speech compresion scores from a modified BIDs events table
rating = events.diffulty_ratings(events.value==131);
qscore = events.questionnaire_scores(events.value==131);
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

for gr = 1 : 2
    switch gr
        case 1
            dplot_st = [ds.ratingST(strcmp(ds.hearing_status,'nh'),1) ds.ratingST(strcmp(ds.hearing_status,'hi'),1)];
            dplot_tt = [ds.ratingTT(strcmp(ds.hearing_status,'nh'),1) ds.ratingTT(strcmp(ds.hearing_status,'hi'),1)];
            ylab     = 'Difficulty rating';
            yl       = [0 100];
        case 2
            dplot_st = [ds.scoreST(strcmp(ds.hearing_status,'nh'),1)  ds.scoreST(strcmp(ds.hearing_status,'hi'),1)];
            dplot_tt = [ds.scoreTT(strcmp(ds.hearing_status,'nh'),1) ds.scoreTT(strcmp(ds.hearing_status,'hi'),1)];
            ylab     = 'Percent correct (%)';
            yl       = [70 100];
    end
    
    
    subplot(1,2,gr)
    errorbar(mean(dplot_st),std(dplot_st)/sqrt(size(dplot_st,1)),'Color',cmap(1,:),'LineWidth',1)
    hold on
    errorbar(mean(dplot_tt),std(dplot_tt)/sqrt(size(dplot_tt,1)),'Color',cmap(2,:),'LineWidth',1)
    
    xlim([0.5 2.5]); ylim(yl); ylabel(ylab);
    set(gca,'xtick',1:2); set(gca,'xticklabel',{'NH','HI'})
    set(gca,'Fontsize',8); set(gca,'TickDir','out');
    set(gca,'TickLength',[0.009, 0.6])
    box off
    
end
cd(fullfile(fileparts(which('initdir.m')),'reports','paper','fig1'))
print('figure-01-p001.pdf','-dpdf')


fig = figure;
set(fig, 'Units', 'centimeters')
fig.Position = [3.4925 3.4925 5.8 4.8];
h1 = plot(0,'Color',cmap(1,:),'LineWidth',1);
hold on
h2 = plot(0,'Color',cmap(2,:),'LineWidth',1);
hleg = legend({'Single-talker','Two-talker'});
hleg.Box = 'off';
hleg.Location = 'southoutside';
hleg.FontSize = 8;
axis off
cd(fullfile(fileparts(which('initdir.m')),'reports','paper','fig1'))
print('figure-01-p002.pdf','-dpdf')
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


for tt =1 : length(varoi)
    clear g
    cmap = [shift(tt) shift(tt) shift(tt);shift(tt) shift(tt) shift(tt)];
    
    close all
    
    figure
    fig = get(groot,'CurrentFigure');
    set(fig, 'Units', 'centimeters')
    fig.Position = [3 3 3.6 3];
    
    
    
    g(1,1)=gramm('x',ds.hearing_status,'y',ds.(varoi{tt}),'color',ds.hearing_status);
    g(1,1).set_names('x','','y',ylab{tt},'color','');
    g(1,1).stat_boxplot('width',sw)
    g(1,1).no_legend();
    g(1,1).set_color_options('map',cmap);
    g(1,1).axe_property('fontsize',fsize,'fontweight','Normal')
    g.coord_flip();
    
    g.draw()
    
    set([g(1,1).results.stat_boxplot.outliers_handle],'MarkerSize',2)
    set([g(1,1).results.stat_boxplot.outliers_handle],'MarkerEdgeColor','k')
    
    cd(fullfile(fileparts(which('initdir.m')),'reports','paper','fig2'))
    print(sprintf('figure-02-p%0.3i.pdf',tt+2),'-dpdf')
end

end



function export_audiograms(ds)

Frequencies={'.125' '.25' '.5' '1' '2' '3' '4' '6' '8'};


for gr = 1 : 2
    switch gr
        case 1
            dplot = ds.agram(strcmp(ds.hearing_status,'nh'),:);
        case 2
            dplot = ds.agram(strcmp(ds.hearing_status,'hi'),:);
    end
    
    figure;
    fig = get(groot,'CurrentFigure');
    set(fig, 'Units', 'centimeters')
    fig.Position = [3 3 3.5 4.6];
    
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
    
    cd(fullfile(fileparts(which('initdir.m')),'reports','paper','fig2'))
    print(sprintf('figure-02-p%0.3i.pdf',gr),'-dpdf')
end
end