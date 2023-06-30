%> @file r01f02.m
%> @brief Perform a cross-correlation analysis on audio representations
%> comparable to that reported in doi:10.1152/jn.00527.2016.; 
%> J Neurophysiol 117: 18-27, 2017. Here, we use the
%> same, elegant (and computationally fast) way of extracting speech-onset 
%> envelopes that put emphasis on onsets. Note that we focus on speech
%> stimuli without CamEQ for hearing-impaired listeners as in the
%> aforementioned study. Also note that we take a few shortcuts for 
%> simplicity(DSS-based EOG denoising, averaging EEG data over a set of 
%> fronto-central electrodes), and that and this is NOT meant as a 
%> direct comparison. This approach is useful for highlighting
%> stimulus-response relations without having to go into the
%> computationally intensive modeling approach
%>
%> One important consideration that we want to highlight is that the premise
%> for using the frequency-dependent CamEQ equalization is that the
%> hearing-impaired listeners have a loss of sensitivity to certain 
%> frequencies and that this equalization up to some extend accounts for 
%> that. A similar approach has been taken in a number of recent studies. 
%> However, we must stress that one should be careful with testing for 
%> statistical stimulus-response dependencies between envelopes of the actual 
%> stimuli (with CamEQ) for envelope representaitons that are highly 
%> sensitive to CamEQ amplification. This is particularly important for 
%> univariate envelope representations. What can happen is that the
%> different representations themself will drive group-differences in 
%> the stimulus-response dependencies.
%>


function r_cc = r01f02(bidsdir)

if nargin < 1 || isempty(bidsdir); bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end




% Define where the BIDs data is located and which subject you are interested in
initdir
global showcomments
showcomments = 0;


cameq = 'woa';

for subid   = 1:44
    if strcmp(cameq,'wa')
        warning('Please be aware that the "speech-onset envelope" representation')
        warning('is highly sensitive to high-frequency amplification')
        warning('This makes it difficult to compare results obtained with ')
        warning('and without CamEQ. An analysis with CamEQ could here')
        warning('introduce group-level biases due to different onset')
        warning('representations')
    end
    
    
    fprintf('\n Processing data from subject %i of %i',subid,44)
    rng('default'); parcreaterandstream(44, randi(10000)+subid)
    
    tic;
    
    paud        = struct;
    paud.task   = 'selectiveattention';
    paud.sname  = '';
    paud.pp = ...
                {'pp_aud_average',...
                'pp_aud_lowpass6000_44100',...
                'pp_aud_resample12000_44100',...
                'pp_aud_hilbert',...
                'pp_aud_lowpass25_butter'...
                'pp_aud_firstorder_diff',...
                'pp_aud_halfwave_rectify',...
                'pp_aud_resample128_12000',...
                'pp_aud_toi_attention_128'};

    
    
    audfeat     = build_aud_features(subid,paud,bidsdir,[],cameq); 
    
    
    % EEG preprocessing
    
    peeg        = struct;
    peeg.task   = 'selectiveattention';
    peeg.sname  = '';
    peeg.pp     = ...
                {'pp_ft_resample128',...
                'pp_ft_bandpass_1_45',...
                'pp_ft_reref_mastoids',...
                'pp_ft_reref_bipolareog',...
                'pp_ft_segmenttrials_attention',...
                'pp_ft_appenddatafromsessions_attention',...
                'pp_ft_eogdenoise',...
                'pp_ft_toi_attention'};

    
    eegfeat    = build_eeg_features(subid,peeg,bidsdir,[]);
    
    fs         = 128;

    % Perform the cross correlation analysis   
    itt = find(strcmp([audfeat.single_talker_two_talker{:}],'twotalker'));
    ist = find(strcmp([audfeat.single_talker_two_talker{:}],'singletalker'));
    
    
    % as in the case of the ERP analysis and the encoding analysis, we here
    % focus on a smaller subset of electrodes (a cluster of fronto-central
    % electrodes)
    roi     = [4 5 6 9 10 11 39 40 41 44 45 46  38 47];
    
    
    
    % compute the crosscorrelation over a relatively small range of lags
    % (as in doi:10.1152/jn.00527.2016). we use "xcorr" to compute the
    % crosscorrelation and focus on normalized scores (i.e. scores
    % normalized such that the auto-correlations at zero lag are
    % identically to 1.0; e.g. c.f. Kong et al., 2016).
    
    for cond = 1 : 3
        
        % loop over the two conditions (single-talker and two-talker). in
        % the two-talker case, we focus both on attended and unattended
        % speech envelopes.
        clear eeg env
        switch cond
            case 1
                eeg = cat(2,eegfeat.trial{ist(:)})';
                env = cat(1,audfeat.target{ist(:)});
            case 2
                eeg = cat(2,eegfeat.trial{itt(:)})';
                env = cat(1,audfeat.target{itt(:)});
            case 3
                eeg = cat(2,eegfeat.trial{itt(:)})';
                env = cat(1,audfeat.masker{itt(:)});
                
        end
        
        % average the eeg responses over the region of interest (as in ERP
        % analysis)
        eeg_mean_over_roi = mean(eeg(:,roi),2);
             
        [r_cc{subid,cond},lags] = xcorr(eeg_mean_over_roi,env,200,'coeff');
        
        
        
    end
    fprintf('\n Time elapsed for a single subject: %f',toc);
    
end

participants = ioreadbidstsv(fullfile(bidsdir,'participants.tsv'));

export01f02fig(r_cc,participants,fs,lags)

end











function export01f02fig(r_cc,participants,fs,lags)


figure
cmp =  [0.7020    0.8039    0.8902; ...
        0.9843    0.7059    0.6824];
      
lagoi  = lags/fs<=0.16 & lags/fs >= 0.09;
boxlag = [0.09 0.16 -0.04 0.04];


condition = {'Single-talker',...
            'Two-talker (attended)',...
            'Two-talker (unattended)'};

% we loop over the three specified conditions
for i = 1 : 3
    
    nhid = strcmp(participants.hearing_status,'nh');
    hiid = strcmp(participants.hearing_status,'hi');
    
    % define two arrays in which each row contain data from a single
    % subject in each group
    dplot_nh = cat(2,r_cc{nhid,i})';
    dplot_hi = cat(2,r_cc{hiid,i})';
  
   
    % first, we plot the mean r_crosscorr over the specified range of
    % interest
    dplot_nh_lagoi = mean(dplot_nh(:,lagoi),2);
    dplot_hi_lagoi = mean(dplot_hi(:,lagoi),2);
    
    subplot(1,4,4)
    
    
    xl  = [1 4 7];
    hb{1} = bar(xl(i),mean(dplot_hi_lagoi),'FaceColor',cmp(2,:));
    hold on
    hb{2} = bar(xl(i)+1,mean(dplot_nh_lagoi),'FaceColor',cmp(1,:));

    % add individual points to the plot
    plot(repmat(xl(i),numel(dplot_hi_lagoi),1),dplot_hi_lagoi,'.','Color',[0.8 0.8 0.8]-0.1)
    plot(repmat(xl(i)+1,numel(dplot_nh_lagoi),1),dplot_nh_lagoi,'.','Color',[0.8 0.8 0.8]-0.1)

    
    % add errorbars to the plot
    errorbar(xl(i),mean(dplot_hi_lagoi),std(dplot_hi_lagoi)/sqrt(numel(dplot_hi_lagoi)),'Color','k')
    errorbar(xl(i)+1,mean(dplot_nh_lagoi),std(dplot_nh_lagoi)/sqrt(numel(dplot_nh_lagoi)),'Color','k')
    
    xlim([0 9]); xtickangle(25)
    
    
    if i == 3
    set(gca,'xtick',xl+0.5)
    set(gca,'xticklabel',condition)
    hleg = legend({'HI','NH'}); hleg.Location = 'northeast';
    hleg.Box = 'off'; box off
    ylabel('Average r_{crosscorr}');
    set(gca,'TickDir','out'); set(gca,'TickLength',[0.006 0.08])
    set(gca, 'YDir','reverse')
    title({'r_{crosscorr} averaged over','highlighted time period'},'FontWeight','Normal')
    end
    
    % plot errorbars with s.e.m
    subplot(1,4,i)
    
    % add gray background traces
    plot(lags/fs,dplot_nh,'Color',[0.9500    0.9500    0.9500])
    hold on
    plot(lags/fs,dplot_hi,'Color',[0.9500    0.9500    0.9500])
 
    % add shaded errorbars
    h1 = shadedErrorBar(lags/fs,mean(dplot_nh),std(dplot_nh)/sqrt(sum(nhid)),'lineprops',{'-','Color',cmp(1,:),'MarkerFaceColor',cmp(1,:),'LineWidth',2},'transparent',0);
    hold on
    h2 = shadedErrorBar(lags/fs,mean(dplot_hi),std(dplot_hi)/sqrt(sum(hiid)),'lineprops',{'-','Color',cmp(2,:),'MarkerFaceColor',cmp(2,:),'LineWidth',2},'transparent',0);
    
    % finally, we highlight the defined time period of interest
    plot([boxlag(1) boxlag(2)],[1 1]*-0.04,'-k','LineWidth',4)


    hleg = legend([h1.mainLine,h2.mainLine],'NH','HI');
    hleg.Box = 'off';
    set(gca,'TickDir','out'); set(gca,'TickLength',[0.03, 2])
    box off; axis square;
    axis square; axis xy;
    title(condition{i},'FontWeight','Normal')
    xlabel('Time-lags (s)')
    ylabel('r_{crosscorr}')
    xlim([-0.2 0.5])
    ylim([-1 1]*0.04)
    set(gca,'Fontsize',8)

    
  
end

fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [22.9113 13.3671 25.5539 13.5210];
text(-0.5,0.15,{'Cross-correlation analysis comparable to that in','J Neurophysiol. 2017 Jan 1;117(1):18-27. doi: 10.1152/jn.00527.2016'},'HorizontalAlignment','Center')

cd(fullfile(fileparts(which('initdir.m'))))
print(fullfile(pwd,'reports','review','review01','fig02','r0102.pdf'),'-dpdf')

end