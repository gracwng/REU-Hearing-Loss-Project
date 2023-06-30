%> @file r01f03.m
%> @brief Plots scatter plots, where different entrainment measures are
%> plotted against difficulty ratings. We here show data for reconstruction
%> accuracies and classification accuracies as thes are univariate measures.
%> For illustrative purposes, we show a global regression curve for each 
%> subplot. It is not suprising that group differences appear to drive 
%> correlations across groups. Note that for SSQ scores, higher values 
%> indicate less listening difficulties. We do not find that the measures 
%> are consistently correlated within groups when considering the two 
%> groups separately. Yet, we do not think that we can conclude anything 
%> from this, since the study was essentially designed as a group study 

function r01f03()

% Define where the BIDs data is located and which subject you are interested in
initdir

load data_summary

fig = figure;
fig.Units = 'centimeters';
fig.Position = [3.4925 6 35.2778*0.6 17.6389*0.6];

nhindex = strcmp(dtab.hearing_status,'nh');
hiindex = strcmp(dtab.hearing_status,'hi');

for i = 1 : 8
    switch i
        case 1
            x = dtab.reconstruction_accuracy(:,1);
            y = dtab.ratingST(:,1);
            xlab = 'r_{single-talker}';
            ylab = 'Difficulty rating (single-talker)';
            
        case 2
            x = dtab.reconstruction_accuracy(:,2);
            y = dtab.ratingTT(:,1);
            
            xlab = 'r_{two-talker, attended}';
            ylab = 'Difficulty rating (two-talker)';
        case 3
            x = dtab.reconstruction_accuracy(:,3);
            y = dtab.ratingTT(:,1);
            
            xlab = 'r_{two-talker, ignored}';
            ylab = 'Difficulty rating (two-talker)';
            
        case 4
            x = dtab.classification_accuracy;
            y = dtab.ratingTT(:,1);
            
            xlab = 'Classification accuracy';
            ylab = 'Difficulty rating (two-talker)';
            
        case 5
            x = dtab.reconstruction_accuracy(:,1);
            y = dtab.SSQall(:,1);
            xlab = 'r_{single-talker}';
            ylab = 'SSQ (all)';
            
        case 6
            x = dtab.reconstruction_accuracy(:,2);
            y = dtab.SSQall(:,1);
            
            xlab = 'r_{two-talker, attended}';
            ylab = 'SSQ (all)';
        case 7
            x = dtab.reconstruction_accuracy(:,3);
            y = dtab.SSQall(:,1);
            
            xlab = 'r_{two-talker, ignored}';
            ylab = 'SSQ (all)';
            
        case 8
            x = dtab.classification_accuracy;
            y = dtab.SSQall(:,1);
            
            xlab = 'Classification accuracy';
            ylab = 'SSQ (all)';
            
            
    end
    subplot(2,4,i)
    figcorrsubpanel(x,y,dtab.hearing_status);
    
    xlabel(xlab)
    ylabel(ylab)
    set(gca,'Fontsize',8)

end


cd(fullfile(fileparts(which('initdir.m'))))
print(fullfile(pwd,'reports','review','review01','fig03','r0103.pdf'),'-dpdf','-r0')


end




function [hall,ha,hb]=figcorrsubpanel(x,y,hearing_status)

load rdbu
cmap = cmap([5,end-5],:);

nhindex = strcmp(hearing_status,'nh');
hiindex = strcmp(hearing_status,'hi');


% first we plot all of the data points together. note that we enforce the
% plotting to only focus on the first column. the reason for plotting the
% data is to use <lsline> to plot an illustrative least-squares fit line to
% the scatter plot
hall = plot(x(:,1),y(:,1),'ko','MarkerSize',2);
lsline


hold on


% plot the data for the normal hearing listeners
plot(x(nhindex,1),y(nhindex,1),...
    'o','MarkerFaceColor',cmap(1,:),'MarkerEdgeColor',[1 1 1],'MarkerSize',5)


% plot the data for the hearing impaired listeners
plot(x(hiindex,1),y(hiindex,1),...
    'o','MarkerFaceColor',cmap(2,:),'MarkerEdgeColor',[1 1 1],'MarkerSize',5)


axis square
box off

set(gca,'TickDir','out');
set(gca,'TickLength',[0.03, 0.4]*0.2)
set(gca,'Fontsize',12)
end


