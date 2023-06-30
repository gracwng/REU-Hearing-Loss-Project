%> @file  extract_classification_results.m
%> @brief Export panels in figure 4 and additional figures highlighting
%> classification accuracies as a function of decoding segment duration

%> history
%> 2019/07/08 added comments 
%> 2019/08/07 updated figure name


function dtab = extract_classification_results(sdir,bidsdir,pipeline_aud_attention,pipeline_eeg_attention,wa,do_plot)

if nargin < 1 || isempty(sdir);     sdir    = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/'; end
if nargin < 2 || isempty(bidsdir);  bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end

% import the BIDs events file which contains information about each
% participant and their hearing status (<nh> or <hi>)
participants_tsv = ioreadbidstsv(fullfile(bidsdir,'participants.tsv'));


% prepare two vectors that contain classification accuracies (<class_acc>)
% and reconstruction accuracies (<rval>; first column is r_attended, second 
% column is r_unattended)
rval = [];
class_acc = [];

for subid = 1 : 44
    fprintf('\n proccesing data from subject %i of %i',subid,44)
    clear dat
    fname = fullfile(sdir,'results',sprintf('sub-%0.3i_classification_%s-%s-%s.mat',subid,pipeline_aud_attention.sname,pipeline_eeg_attention.sname,wa));
    load(fname);
 
    % once the data summary has been imported, then loop over all decoding
    % segments <[0.5000 2.5000 4.5000 6.5000 9.5000 14.5000 19.5000
    % 29.5000]>. Since the number of classification decisions considered
    % depends on the length of the decoding segments, we here estimate
    % chance level for each duration
    for n =  1 : numel(dataout.classification_results.vlog)
        
        % prepare an array <class_acc> and <t_dur> that contains
        % results from individual subjects for the given decoding length
        % note that we here manually extend the duration of the decoding 
        % segment by the decoding model's kernel length
        class_acc(subid,n) = dataout.classification_results.vlog{n}.cacc;
        t_dur(subid,n) = dataout.classification_results.vlog{n}.opts.tdur(n)+0.5;
        
        
        % since we plot the reconstruction accuracies on a single-trial
        % basis we simply concatenate along the first dimension
        if  dataout.classification_results.vlog{n}.opts.tdur(n) == 9.5
            rval = [rval; dataout.classification_results.vlog{n}.cval];
            
            % the following is not necessary, but merely to illustrate that
            % the classification accuracies is based on the
            % entries in <rval> for the given subject and decoding duration
            if mean(dataout.classification_results.vlog{n}.cval(:,1)>dataout.classification_results.vlog{n}.cval(:,2))~=class_acc(subid,n)
                error('something is wrong!')
            end
        end
        
        % finally, we asumme that the classification accuracies follow a
        % binomial distribution. note that the following is completely
        % unnecessary:
        % <size(dataout.classification_results.vlog{n}.cval,1)> is
        % identicial for all subjects and the array <class_acc_nf> will
        % thus contain replicas of the same values.  
        class_acc_nf(subid,n) = binoinv(0.975,size(dataout.classification_results.vlog{n}.cval,1),0.5)/size(dataout.classification_results.vlog{n}.cval,1);
    end
end


% the results presented in the main text only rely on classification
% accuracies with 10-s long decoding segments. find the column in 
% <class_acc>  that contain these values and export them to the <dtab> table
[~,mid]= min(abs(t_dur(1,:)-10));
dtab = table(participants_tsv.participant_id,participants_tsv.hearing_status,class_acc(:,mid));
dtab.Properties.VariableNames = {'participant_id','hearing_status','classification_accuracy'};


% finally, export the relevant figures:
%   1) bar plot of classification accuracies 
%   2) scatter plot of r_attended and r_unattended
%   3) errorbar plot of classification accuracies as a function of decoding
%   segment length
if do_plot
    export_classification_figure(dtab,class_acc_nf(1,mid),wa);
    export_classification_recacc_figure(rval,wa);
    export_classification_acc_time(participants_tsv,t_dur,class_acc,class_acc_nf,wa)
end




end




















function export_classification_figure(dtab,chance_level,wa)

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
g(1,1).geom_hline('yintercept',chance_level*100,'style','k--','LineWidth',1);
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

cd(fullfile(fileparts(which('initdir.m')),'reports','paper','fig4'))
print('figure-04-p001.pdf','-dpdf','-r500')

end











function export_classification_recacc_figure(rval,wa)

cmap = [0.4 0.4 0.4; 0.8 0.8 0.8];
rng('default')
figure
fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [3 3 5.5,5.5];

clear g
g=gramm('x',rval(:,1),'y',rval(:,2));
g.geom_point();
g.stat_cornerhist('edges',linspace(-0.5,0.5,100),'aspect',0.5);
g.geom_abline();
g.axe_property('fontsize',8,'fontweight','Normal')
g.set_title('');
g.axe_property('XLim',[-0.5 1]);
g.axe_property('YLim',[-0.5 1]);
g.set_color_options('map',[cmap(1,:); cmap(end,:)]);
g.set_names('color','','x','r_{attend}','y','r_{unattend}');
g.set_text_options('font','Helvetica')
g.draw();
set([g.results.geom_point_handle],'MarkerSize',1);
set([g.results.stat_cornerhist.child_axe_handle],'XTick',[])

cd(fullfile(fileparts(which('initdir.m')),'reports','paper','fig4'))
print('figure-04-p002.pdf','-dpdf','-r500')

end



function export_classification_acc_time(participants_tsv,t_dur,class_acc,class_acc_nf,wa)
nhid = strcmp(participants_tsv.hearing_status,'nh');
hiid = strcmp(participants_tsv.hearing_status,'hi');

figure
fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [3 3 8.5,10.5];
cmp = [   0.4157    0.4157    0.4157; ...
          0.7412    0.7412    0.7412];
 for i = 1:2
    plot(0,0,'Marker', 'o','LineStyle','none','Color',cmp(i,:)); hold on;
 end

 plot(t_dur(1,:),class_acc_nf(1,:),'--k','LineWidth',1);

xhi =  class_acc(hiid,:);
xnh =  class_acc(nhid,:);

% for the errorbar plot in the *additional* folder, we shift the errorbars
% around their actual value for visualization purposes
ha = errorbar(t_dur(1,:)+0.2,mean(xhi,1),std(xhi,1),'o','Color',cmp(1,:),'LineWidth',1);
hold on
hb = errorbar(t_dur(1,:)-0.2,mean(xnh,1),std(xnh,1),'o','Color',cmp(2,:),'LineWidth',1);
ylim([0.5 1.05])
box off
xlabel('Duration (s)'); ylabel('Classification accuracy')
set(gca,'FontSize',8)
hleg  =legend('HI','NH','Chance');
hleg.FontSize = 8;
axis square;
hleg.Location = 'southoutside';
hleg.Box = 'off';

cd(fullfile(fileparts(which('initdir.m')),'reports','paper','additional'))
print('figure-classification_accuracy_time.png','-dpng','-r500')
end