% this function exports figures that illustrate how CamEQ filtering
% in the stimulus-response analysis affect the regression accuracies
% for encoding and stimulus-reconstruction models. 

function figure_regression_accuracies_cameq(sdir,bidsdir)

if nargin < 1 || isempty(sdir);     sdir    = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/'; end
if nargin < 2 || isempty(bidsdir);  bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end

do_plot = 0;
savesummary = 0;


% we extract data from <sdir> and use this data to plot encoding
% and reconstruction accuracies for models trained on audio with- or
% without CamEQ
dtab_woa = export_summaries(sdir,bidsdir,do_plot,'woa',savesummary);
dtab_woacontrol = export_summaries(sdir,bidsdir,do_plot,'woacontrol',savesummary);
dtab_wa = export_summaries(sdir,bidsdir,do_plot,'wa',savesummary);



cmap = colormap(jet(5));

close all

figure
fig = figure;
fig.Units = 'centimeters';
fig.Position = [3.4925 6 21.2 12];
for type = 1 : 3
    
    switch type
        case 1
            xx = dtab_woa.encoding_accuracy;
            yy = dtab_wa.encoding_accuracy;
            xlab = 'CamEQ = woa';
            ylab = 'CamEQ = wa';
            
        case 2
            xx = dtab_woa.encoding_accuracy;
            yy = dtab_woacontrol.encoding_accuracy;
            xlab = 'CamEQ = woa';
            ylab = 'CamEQ = woacontrol';
        case 3
            xx = dtab_woacontrol.encoding_accuracy;
            yy = dtab_wa.encoding_accuracy;
            xlab = 'CamEQ = woacontrol';
            ylab = 'CamEQ = wa';
    end
    
    
    
    subplot(2,3,type)
    hs = {};
    for c = 1 : 3
        hs{c} = plot(xx(:,c),yy(:,c),'o','MarkerFaceColor',cmap(c,:),'MarkerEdgeColor',[1 1 1],'MarkerSize',8);
        hold on
    end
    plot([0 0.3],[0 0.3],'--k'); xlim([0 0.25]); ylim([0 0.25])
    axis square
    xlabel(xlab); ylabel(ylab)
    title({'Encoding accuracy','(averaged over ROI)'},'FontWeight','Normal')
    figfillplot
    hleg = legend([hs{1},hs{2},hs{3}],'r_{st}','r_{att}','r_{itt}');
    hleg.Location = 'southeast';
    hleg.Box = 'off';
end




for type = 1 : 3
    
    switch type
        case 1
            xx = dtab_woa.reconstruction_accuracy;
            yy = dtab_wa.reconstruction_accuracy;
            xlab = 'CamEQ = woa';
            ylab = 'CamEQ = wa';
            
        case 2
            xx = dtab_woa.reconstruction_accuracy;
            yy = dtab_woacontrol.reconstruction_accuracy;
            xlab = 'CamEQ = woa';
            ylab = 'CamEQ = woacontrol';
        case 3
            xx = dtab_woacontrol.reconstruction_accuracy;
            yy = dtab_wa.reconstruction_accuracy;
            xlab = 'CamEQ = woacontrol';
            ylab = 'CamEQ = wa';
    end
    
    
    subplot(2,3,type+3)
    hs = {};
    for c = 1 : 3
         hs{c} = plot(xx(:,c),yy(:,c),'o','MarkerFaceColor',cmap(c,:),'MarkerEdgeColor',[1 1 1],'MarkerSize',8);
        hold on
    end
    plot([0 0.5],[0 0.5],'--k'); xlim([0 0.5]); ylim([0 0.5])
    axis square
    xlabel(xlab); ylabel(ylab)
    title('Reconstruction accuracy','FontWeight','Normal');
    figfillplot
       hleg = legend([hs{1},hs{2},hs{3}],'r_{st}','r_{att}','r_{itt}');
    hleg.Location = 'southeast';
    hleg.Box = 'off';
end

fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
cd(fullfile(fileparts(which('initdir.m'))))
print(fullfile(pwd,'reports','dataset','figure_regression_accuracies_cameq','figure_regression_accuracies_cameq.png'),'-dpng','-r500')

end














function figfillplot

xlim = get(gca,'xlim'); ylim = get(gca,'ylim');
hold on
X = [linspace(xlim(1),xlim(2),100) fliplr(linspace(xlim(1),xlim(2),100))];
Y = [repmat(ylim(2),1,100) repmat(ylim(1),1,100)];
col = [linspace(0, 1,100)]

Hpatch = fill(X,Y,'b')
cdata=get(Hpatch,'ydata');
cdata=(cdata-min(cdata))/(max(cdata)-min(cdata));

set(Hpatch,'CData',cdata,'FaceColor','interp','Facealpha',0.1,'Edgealpha',0);
colormap('gray');
box off;


end

