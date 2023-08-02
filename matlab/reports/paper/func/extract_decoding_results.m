%> @file  extract_decoding_results.m
%> @brief Export figure showing stimulus reconstruction accuracies
%> obtained with each model

%> history
%> 2019/07/08 added comments 

function dtab = extract_decoding_results(sdir,bidsdir,pipeline_aud_attention,pipeline_eeg_attention,wa,do_plot)

if nargin < 1 || isempty(sdir);     sdir    = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/'; end
if nargin < 2 || isempty(bidsdir);  bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end

% import the BIDs events file which contains information about each
% participant and their hearing status (<nh> or <hi>)
participants_tsv = ioreadbidstsv(fullfile(bidsdir,'participants.tsv'));


% as described in the text we estimate noise floor based on surrogate data
% across all subjects and conditions
perm_all = [];
for subid = 1 : 44
    
    % import the data from each subject
    fprintf('\n proccesing data from subject %i of %i',subid,44)
    clear dat
    fname = fullfile(sdir,'results',sprintf('sub-%0.3i_reconstruction_%s-%s-%s.mat',subid,pipeline_aud_attention.sname,pipeline_eeg_attention.sname,wa));
    load(fname);
    
    
    % the reconstruction accuracies are here estimated as an average over
    % all 10 folds (i.e. <numel(dataout.reconstruction_results.vlog_st)>).
    % the number of folds is identicial for both single-talker condition
    % and two-talker condition. the reconstruction accuracies are stored in
    % the cellstruct as an entry with the name <acco>. we prepare an output
    % array and fill up the array along the third dimension
    cval = []; cval_p = [];
    for n =  1 : numel(dataout.reconstruction_results.vlog_st)
        cval(:,1,n) = dataout.reconstruction_results.vlog_st{n}.acco;
        cval(:,2,n) = dataout.reconstruction_results.vlog_att{n}.acco;
        cval(:,3,n) = dataout.reconstruction_results.vlog_itt{n}.acco;
        
        
        % in addition to this, we do exactly the same thing for the
        % estimation of the noise floor. since we want to do exactly the
        % same thing for this quantity, we also average across all outer
        % folds. each quantity
        % <dataout.reconstruction_results.vlog_st{n}.opts.phaserand.accsurr>
        % is a vector of size [1000 x 1] for this study as we here
        % repeated this process 1000 times for each condition and subject
        cval_p(:,1,n) = dataout.reconstruction_results.vlog_st{n}.opts.phaserand.accsurr;
        cval_p(:,2,n) = dataout.reconstruction_results.vlog_att{n}.opts.phaserand.accsurr;
        cval_p(:,3,n) = dataout.reconstruction_results.vlog_itt{n}.opts.phaserand.accsurr;
        
    end
    
    % finally we average data over all outer folds and prepare to arrays
    % <perm_all> and <acc>. the former contains results obtained with
    % surrogate data stacked over all subjects and conditions
    cval_p = mean(cval_p,3);
    cval = mean(cval,3);
    
    perm_all = [perm_all; cval_p(:)];
    acc(subid,:) = cval;
end


% export the output to the <dtab> table. note that we here consider the
% 97.5 % percentile
dtab = table(participants_tsv.participant_id,participants_tsv.hearing_status,acc,repmat(prctile(perm_all,97.5),size(acc,1),1));
dtab.Properties.VariableNames = {'participant_id','hearing_status','reconstruction_accuracy','reconstruction_noise_floor'};

if do_plot
export_reconstruction_accuracy_barplot(participants_tsv,dtab,wa)
end

end









function export_reconstruction_accuracy_barplot(participants_tsv,dtab,wa)
figure
myax = axes;

hold on

cmp = [0.4157 0.4157  0.4157;...
      0.8510  0.8510  0.8510];

nhid = strcmp(participants_tsv.hearing_status,'nh');
hiid = strcmp(participants_tsv.hearing_status,'hi');


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
hleg.Location = 'northeast';
hleg.Box = 'off';
box off; ylim([0 0.45]);
set(gca,'Fontsize',8)
xtickangle(25); xlim([0 9])
set(gca,'TickDir','out');
set(gca,'TickLength',[0.006  0.08])

myax.Layer = 'top';

fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
%fig.Position = [3 3 4.6,9];
fig.Position = [3 3 4.232 8.28];

cd(fullfile(fileparts(which('initdir.m')),'reports','paper','additional'))
print('figure-reconstruction_accuracy.png','-dpng','-r500')
end







