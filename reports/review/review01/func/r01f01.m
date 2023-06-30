%> @file  r01f01.m
%> @brief Evaluating the goodness-of-fit in the two-talker condition of 
%> encoding- and decoding models trained on single-talker data. 
%> @param sdir directory in which the derived data is stored
%> @param bidsdir directory in which the source data is stored
%> @param cameq 'woa'/'wa'/'woacontrol'
%> @param do_plot a flag (1/0) indicating whether or not you want to
%> plot the output. Default = 1 (i.e. store data) 




function dtab = r01f01(sdir,bidsdir,cameq,do_plot)

if nargin < 1 || isempty(sdir);     sdir    = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/'; end
if nargin < 2 || isempty(bidsdir);  bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end
if nargin < 3 || isempty(cameq);    cameq   = 'woa'; end
if nargin < 4 || isempty(do_plot);  do_plot = 1; end


workflows_paper

% import the BIDs events file which contains information about each
% participant and their hearing status (<nh> or <hi>)
participants_tsv = ioreadbidstsv(fullfile(bidsdir,'participants.tsv'));

% for the statistical analysis of the encoding accuracies we average the
% accuracies over a cluster of fronto-central electrodes. these correspond
% to the following columns in the data summaries
roi     = [4 5 6 9 10 11 39 40 41 44 45 46 38 47];

% as described in the text we estimate noise floor based on surrogate data
% across all subjects and conditions
perm_all = []; rperm_all = [];
for subid = 1 : 44
    
    % import the data from each subject
    fprintf('\n proccesing data from subject %i of %i',subid,44)
    clear dat
    fname = fullfile(sdir,'results',sprintf('sub-%0.3i_regressionacc_train_on_st_%s-%s-%s.mat',subid,pipeline_aud_attention.sname,pipeline_eeg_attention_st_denoising.sname,cameq));
    load(fname);
    
    % the encoding accuracies are here estimated as an average over all of
    % the 32 two-talker trials
    
    assert(any(roi==dataout.vlog_f.surr_dat{1}.sur_roi_att),'ROI does not match stimulus-response analysis');
    
    cval = []; cval_p = [];
    for n =  1 : size(dataout.vlog_f.pacc,1)
        cval(:,1,n) = dataout.vlog_f.pacc(n,:,1);
        cval(:,2,n) = dataout.vlog_f.pacc(n,:,2);
        
        cval_p(:,1,n) = dataout.vlog_f.surr_dat{n}.sur_acc_att;
        cval_p(:,2,n) = dataout.vlog_f.surr_dat{n}.sur_acc_dtt;
    end
    
    % similarly, the decoding accuracies are estimated as an average over all of
    % the 32 two-talker trials
    
    rval = []; rval_p = [];
    for n =  1 : size(dataout.vlog_f.pacc,1)
        rval(:,1,n) = dataout.vlog_b.pacc(n,:,1);
        rval(:,2,n) = dataout.vlog_b.pacc(n,:,2);
        
        rval_p(:,1,n) = dataout.vlog_b.surr_dat{n}.sur_acc_att;
        rval_p(:,2,n) = dataout.vlog_b.surr_dat{n}.sur_acc_dtt;
    end
        
    % we average the data over all fold. this is also done for the
    % surrogate data
    
    cval_p = mean(cval_p,3);
    cval = mean(cval,3);
    
    rval_p = mean(rval_p,3);
    rval = mean(rval,3);
    
    % stack the results obtained with surrogate data. <perm_all> relate to
    % encoding accuracies (averaged over a roi) and <rperm_all> relate to
    % stimulus reconstruction accuracies
    
    perm_all = [perm_all; cval_p(:)];
    rperm_all = [rperm_all; rval_p(:)];

    
    % prepare an array
    acc(subid,:) = mean(cval(roi,:));
    racc(subid,:) = rval;
    
    
    
    % for illustrative purposes, we also highlight the weights of the
    % decoding models. this is done to better illustrate "how" one maps
    % from EEG response to target envelope. note that this should be taken
    % with a grain of salt (e.g. due to interpretability of decoding
    % weights, filtering impact on response functions etc etc)
    lagoi = dataout.weights.lagoi;
    nlag = numel(dataout.weights.lagoi);
    nch = 65;
    funreshape = @(x) reshape(x,nch,nlag);
    
    ww(:,:,subid,1) = funreshape(dataout.weights.wwst);
    ww(:,:,subid,2) = funreshape(dataout.weights.wwatt);
    ww(:,:,subid,3) = funreshape(dataout.weights.wwitt);
    
end


% export the <dtab> table
dtab = table(participants_tsv.participant_id,participants_tsv.hearing_status,acc,repmat(prctile(perm_all,97.5),size(acc,1),1),racc,repmat(prctile(rperm_all,97.5),size(acc,1),1));
dtab.Properties.VariableNames = {'participant_id','hearing_status','encoding_accuracy_train_st','enc_noise_floor_train_st','reconstruction_accuracy_train_st','r_noise_floor_train_st'};

if do_plot
    export_regression_accuracies_models_trained_on_st_figure(dtab);
    h = text(9,0.425,{'Weights of stimulus-reconstruction','filters at individual time lags'},'HorizontalAlignment','Center'); %h.FontSize = 8;
    toposubplots(ww,lagoi,dtab)
    cd(fullfile(fileparts(which('initdir.m'))))
    print(fullfile(pwd,'reports','review','review01','fig01','r0101.pdf'),'-dpdf')
end

end


function export_regression_accuracies_models_trained_on_st_figure(dtab)

figure
fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [15.9208   -1.5449   20.2153   12.7262];%[3.0113 -2.4353 33.1771 13.7212];%[3.0113 0.4190 14.3235 10.8670];


nhid = strcmp(dtab.hearing_status,'nh');
hiid = strcmp(dtab.hearing_status,'hi');
cmap = [1.0000    0.2222         0;
    1.0000    0.7778         0];

cmapdot = [1.0000    0.5556         0];
for sb = 1 : 2
    if sb == 1
        dplot = dtab.encoding_accuracy_train_st;
        dfloor = dtab.enc_noise_floor_train_st;
        tit = {'Encoding model','trained on single-talker','data and evaluated','on two-talker data'};
        tick = {'r_{model pred,EEG}','r{model pred,EEG}'};
        spid = [ 6    11    16];
    else
        dplot = dtab.reconstruction_accuracy_train_st;
        dfloor = dtab.r_noise_floor_train_st;
        tit = {'Reconstruction model','trained on single-talker','data and evaluated','on two-talker data'};
        spid = [7    12    17];
    end
    
    xa = dplot(nhid,:);
    xb = dplot(hiid,:);
    
    subplot(5,5,spid)
    
    ha = bar([0.8 1.8],mean(xa),'FaceColor',cmap(1,:));
    ha.BarWidth = 0.2;
    hold on
    hb = bar([1.2 2.2],mean(xb),'FaceColor',cmap(2,:));
    hb.BarWidth = 0.2;
    
    errorbar([0.8 1.8],mean(xa),std(xa)/sqrt(size(xa,1)),'.k')
    errorbar([1.2 2.2],mean(xb),std(xb)/sqrt(size(xb,1)),'.k')
    
    plot([repmat(1,size(xa,1),1);repmat(2,size(xa,1),1)]-0.2,xa(:),'.','Color',cmapdot(1,:))
    plot([repmat(1,size(xb,1),1);repmat(2,size(xb,1),1)]+0.2,xb(:),'.','Color',cmapdot(1,:))
    
    
    hl = line([0 3],[1 1]*dfloor(1));
    hl.Color = 'k';
    hl.LineStyle = '-.';
    hl.LineWidth = 1;
    
    xlim([0 3]); ylim([-0.03 0.33])
    set(gca,'xtick',1:2)
    set(gca,'xticklabel',{'Evaluated on attended speech','Evaluated on unattended speech'});
    box off;
    title(tit,'FontWeight','Normal')
    ylabel('Correlation coefficient');
    xtickangle(20)
    hleg = legend([ha hb],{'NH','HI'});
    hleg.Box = 'off';
    set(gca,'Fontsize',8)
    set(gca,'TickDir','out'); set(gca,'TickLength',[0.006 0.08])
end
end


function toposubplots(ww,lagoi,dtab)

hiid = strcmp(dtab.hearing_status,'hi');
nhid = strcmp(dtab.hearing_status,'nh');

tit = {'Single-talker','Two-talker (attend)','Two-talker (ignore)'};
clim = [-0.015 0.015];



l = 20;
for c = 1 : 3
    subplot(5,5,c+2+5)
    nhhitopoplot(nanmean(ww(:,l,hiid,c),3),clim)
    title({sprintf('HI (%0.1f ms)',-lagoi(l)/64*1000),sprintf('w_{%s}',tit{c})},'FontWeight','Normal')
    colorbar
    
    
    subplot(5,5,c+2+5+5)
    nhhitopoplot(nanmean(ww(:,l,nhid,c),3),clim)
    title({sprintf('NH (%0.1f ms)',-lagoi(l)/64*1000),sprintf('w_{%s}',tit{c})},'FontWeight','Normal')
    colorbar
end

l = 27;
for c = 1 : 3
    subplot(5,5,c+2+10+5)
    nhhitopoplot(nanmean(ww(:,l,hiid,c),3),clim)
    title({sprintf('HI (%0.1f ms)',-lagoi(l)/64*1000),sprintf('w_{%s}',tit{c})},'FontWeight','Normal')
    colorbar
    
    subplot(5,5,c+2+15+5)
    nhhitopoplot(nanmean(ww(:,l,nhid,c),3),clim)
    title({sprintf('NH (%0.1f ms)',-lagoi(l)/64*1000),sprintf('w_{%s}',tit{c})},'FontWeight','Normal')
    colorbar
end

end









function nhhitopoplot(dplot,clim,highlightchannels)

if nargin < 2 || isempty(clim); clim = [-1 1]*max(abs(dplot(:)));; end
if nargin < 3 || isempty(highlightchannels); highlightchannels = []; end


load('rdbu.mat'); colormap(cmap);


cfg=[];
cfg.layout='biosemi64.lay';
layout=ft_prepare_layout(cfg);

ft_plot_topo(layout.pos(1:numel(dplot),1), layout.pos(1:numel(dplot),2), dplot',...
    'mask', layout.mask,...
    'outline', layout.outline, ...
    'interplim', 'mask','isolines',0,'style','imsatiso','clim',clim);



if ~isempty(highlightchannels)
    layhighlight = struct;
    fnames = {'pos','width','height','label'};
    for f = 1 : length(fnames)
        layhighlight.(fnames{f}) = layout.(fnames{f})(highlightchannels,:);
    end
    ft_plot_lay(layhighlight,'box','no','label','no','point','yes','pointsymbol','o','pointcolor',[0 0 0],'pointsize',4,...
        'labelsize',20)
end


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
end
