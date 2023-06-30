%> @file  r01f07.m
%> @brief Exports results from an encoding analysis operating on
%> multidimensional cochleograms (based on <runall_binauralhf_FCz.m>) with
%> gammatone center frequencies ERB-spaced between 100 Hz and 12 khz and
%> features extracted for each of the two audio channels. For computational
%> purposes we export data for models trained on the FCz electrode
%> response.
%> @param sdir directory in which the derived data is stored
%> @param bidsdir directory in which the source data is stored
%> @param do_plot a flag (1/0) indicating whether or not you want to
%> plot the output. Default = 1 (i.e. store data) 



function dtab = r01f07(sdir,bidsdir,do_plot,cameq)

if nargin < 1 || isempty(sdir);     sdir    = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/'; end
if nargin < 2 || isempty(bidsdir);  bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end
if nargin < 3 || isempty(do_plot);  do_plot = 1; end
if nargin < 4 || isempty(cameq);    cameq = 'woa'; end

pipeline_aud_binaural_highfreq = struct;
pipeline_aud_binaural_highfreq.task = 'selectiveattention';
pipeline_aud_binaural_highfreq.sname = 'wf_aud_att_binaural_hf'; 


pipeline_eeg_attention = struct;
pipeline_eeg_attention.task = 'selectiveattention';
pipeline_eeg_attention.sname = 'wf_eeg_att';          




% import the BIDs events file which contains information about each
% participant and their hearing status (<nh> or <hi>)
participants_tsv = ioreadbidstsv(fullfile(bidsdir,'participants.tsv'));



perm_all = [];
for subid = 1 : 44
    
    % import the data from each subject
    fprintf('\n proccesing data from subject %i of %i',subid,44)
    clear dataout
    fname = fullfile(sdir,'results',sprintf('sub-%0.3i_encoding_FCz_%s-%s-%s.mat',subid,pipeline_aud_binaural_highfreq.sname,pipeline_eeg_attention.sname,cameq));
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
    acc(subid,:) = cval;
end


% export the <dtab> table
dtab = table(participants_tsv.participant_id,participants_tsv.hearing_status,acc,repmat(prctile(perm_all,97.5),size(acc,1),1));
dtab.Properties.VariableNames = {'participant_id','hearing_status','encoding_accuracy','noise_floor'};

if do_plot
    export_encoding_accuracy_barplot(participants_tsv,dtab);
end



end




















function export_encoding_accuracy_barplot(participants_tsv,dtab)

cmp = colormap(copper(128));
cmp = cmp([40 80],:);
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
ylabel('Encoding accuracy (FCz)');

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
print(fullfile(pwd,'reports','review','review01','fig07','r0107.pdf'),'-dpdf')


end





