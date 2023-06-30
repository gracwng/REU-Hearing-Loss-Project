%> @file  r01f06.m
%> @brief This function is used to re-analyze data when bandpass filtering 
%> the EEG/audio data using constant-bandwidth 2 Hz wide filters before
%> performing the encoding analysis. This is computationally rather
%> expensive.
%> @param bidsdir directory in which the source data is stored
%> @param storedata a flag (1/0) indicating whether or not you want to
%> store the output. Default = 1 (i.e. store data) 


function r01f06(bidsdir,storedata)

if nargin < 1 || isempty(bidsdir); bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end
if nargin < 2 || isempty(storedata); storedata = 0; end

% this function is used to re-analyze data when bandpass filtering the data
% using constant-bandwidth 2 Hz wide filters. this is done to better
% understand if the reported effects are localized in frequency.


% Define where the BIDs data is located and which subject you are interested in
initdir
global showcomments
showcomments = 0;

fbandpass = [2 4 6 8 10];

for subid   = 1 : 44
    
    fprintf('\n Processing data from subject %i of %i',subid,44)
    rng('default'); parcreaterandstream(44, randi(10000)+subid)
    
    for fi = 1 : numel(fbandpass)
        fprintf('\n ======================================================================== ')
        fprintf('\n ======================================================================== ')
        fprintf('\n ======================================================================== \n')
        fprintf('\n Bandpass frequency: %i of %i',fi,numel(fbandpass))
        fprintf('\n Subject %i of %i',subid,44)
        
        global fbp
        fbp = [fbandpass(fi)-1 fbandpass(fi)+1];
        
        tic;
        % Audio preprocessing
        
        % audio data from selective attention experiment
        pipeline_aud_attention = struct;
        pipeline_aud_attention.task = 'selectiveattention';
        pipeline_aud_attention.sname = 'wf_aud_att';
        pipeline_aud_attention.pp = ...
            {'pp_aud_average',...
            'pp_aud_lowpass6000_44100',...
            'pp_aud_resample12000_44100',...
            'pp_aud_gammatone',...
            'pp_aud_fullwave_rectify',...
            'pp_aud_powerlaw03',...
            'pp_aud_average',...
            'pp_aud_lowpass256_12000',...
            'pp_aud_resample512_12000',...
            'pp_aud_lowpass30_512',...
            'pp_aud_resample64_512',...
            'pp_aud_bpfilt_fs64',...
            'pp_aud_toi_attention'};
        
        
        audfeat     = build_aud_features(subid,pipeline_aud_attention,bidsdir,[],'woa');
        
        
        % EEG preprocessing
        
        pipeline_eeg_attention = struct;
        pipeline_eeg_attention.task = 'selectiveattention';
        pipeline_eeg_attention.sname = 'wf_eeg_att';
        pipeline_eeg_attention.pp = {'pp_ft_reref_mastoids',...
            'pp_ft_lowpass30_fs512',...
            'pp_ft_resample64',...
            'pp_ft_highpass05_fs64_attention',...
            'pp_ft_reref_bipolareog',...
            'pp_ft_segmenttrials_attention',...
            'pp_ft_appenddatafromsessions_attention',...
            'pp_ft_eogdenoise',...
            'pp_ft_bpfilt_fs64',...
            'pp_ft_toi_attention'};
        
        
        
        eegfeat    = build_eeg_features(subid,pipeline_eeg_attention,bidsdir,[]);
        
        
        % Prepare a struct that contains the audio and EEG features in the format [time x feature dimensions x trials] for single-talker and two-talker data
        id_st = ismember(cat(1,audfeat.single_talker_two_talker{:}),'singletalker');
        id_tt = ismember(cat(1,audfeat.single_talker_two_talker{:}),'twotalker');
        
        srdat                       = struct;
        srdat.aud_feature.target_st = cat(3,audfeat.target{id_st});
        srdat.aud_feature.target_tt = cat(3,audfeat.target{id_tt});
        srdat.aud_feature.masker_tt = cat(3,audfeat.masker{id_tt});
        srdat.eeg_feature.eeg_st    = permute(cat(3,eegfeat.trial{id_st}),[2 1 3]);
        srdat.eeg_feature.eeg_tt    = permute(cat(3,eegfeat.trial{id_tt}),[2 1 3]);
        
        % Perform the stimulus-response analysis
        opts                        = struct;
        opts.kinner                 = 5;
        opts.kouter                 = 10;
        opts.lambda                 = logspace(-3,6,50);
        opts.znormd                 = 1;
        opts.storew                 = 0;
        opts.gof                    = 'estcorr';
        opts.phaserand.nperm        = 1000;
        
        % Encoding analysis
        rng('default'); parcreaterandstream(44, randi(10000)+subid)
        
        % Example 1: encoding analysis on single-talker data
        lagoi                       = 0:32;
        xx                          = srdat.aud_feature.target_st;
        yy                          = srdat.eeg_feature.eeg_st;
        
        [vlog_encoding_st{subid,fi}] = regevalnestedloopssvdridge(opts,matlag3d(xx,lagoi),yy);
        
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        % Example 2: encoding analysis on two-talker data (attended speech)
        xx                          = srdat.aud_feature.target_tt;
        yy                          = srdat.eeg_feature.eeg_tt;
        
        [vlog_encoding_att{subid,fi}] = regevalnestedloopssvdridge(opts,matlag3d(xx,lagoi),yy);
        
        % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        % Example 3: encoding analysis on two-talker data (ignored speech)
        xx                          = srdat.aud_feature.masker_tt;
        yy                          = srdat.eeg_feature.eeg_tt;
        
        [vlog_encoding_itt{subid,fi}] = regevalnestedloopssvdridge(opts,matlag3d(xx,lagoi),yy);
        
   
        
        fprintf('\n Time elapsed for a single subject: %f',toc);
        
        clear eegfeat audfeat xx yy
        
        
    end
    
    
    if storedata
        cd(fullfile(fileparts(which('initdir.m'))))
        save(fullfile(pwd,'reports','review','review01','fig06','bpresults.mat'),'vlog_encoding_st','vlog_encoding_att','vlog_encoding_itt','fbandpass')
    end
    
end


exportbpencodingfigure(fbandpass,vlog_encoding_st,vlog_encoding_att,vlog_encoding_itt,bidsdir)


end











function exportbpencodingfigure(fbandpass,vlog_encoding_st,vlog_encoding_att,vlog_encoding_itt,bidsdir)



nhz = numel(fbandpass);
nsb = size(vlog_encoding_st,1);

cval = [];
for ii = 1 : nsb
    for ff = 1 : nhz
        
        
        % we considered a 10-fold cross-validation procedure for the outer
        % loops
        cval_outer_loops = [];
        for nn = 1 : 10
            cval_outer_loops(:,1,nn) = vlog_encoding_st{ii,ff}{nn}.acco;
            cval_outer_loops(:,2,nn) = vlog_encoding_att{ii,ff}{nn}.acco;
            cval_outer_loops(:,3,nn) = vlog_encoding_itt{ii,ff}{nn}.acco;
            
        end
        
        cval(:,:,ff,ii) = mean(cval_outer_loops,3);
        fprintf('\n Processing data from subject %i of %i',ii,nsb)
    end
end


% for visualizing the encoding accuracies, average over all scalp
% electrodes (also to minize risk of any potential biases in certain
% frequency ranges and listening conditions)
scalp_electrodes = 1 : 64;

cval_avg = squeeze(mean(cval(scalp_electrodes,:,:,:),1));

participants_info = ioreadbidstsv(fullfile(bidsdir,'participants.tsv'));

nhid = strcmp(participants_info.hearing_status,'nh');
hiid = strcmp(participants_info.hearing_status,'hi');

cmp =  [0.7020    0.8039    0.8902; ...
    0.9843    0.7059    0.6824];


conditions = {'Single-talker','Two-talker (attended)','Two-talker (unattended)'};
figure
fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [2.9898    2.9898   21.8546    7.9904];

for cc = 1 : 3
    dplot_nh = squeeze(cval_avg(cc,:,nhid))';
    dplot_hi = squeeze(cval_avg(cc,:,hiid))';
    
    
    subplot(1,3,cc)
    
    errorbar(fbandpass, mean(dplot_nh), std(dplot_nh)/sqrt(size(dplot_nh,1)),'.','Color',cmp(1,:))
    
    hold on
    errorbar(fbandpass, mean(dplot_hi), std(dplot_hi)/sqrt(size(dplot_hi,1)),'.','Color',cmp(2,:))
    
    h1 = shadedErrorBar(fbandpass,mean(dplot_nh), std(dplot_nh)/sqrt(size(dplot_nh,1)),'lineprops',{'-','Color',cmp(1,:),'MarkerFaceColor',cmp(2,:)});
    h2 = shadedErrorBar(fbandpass,mean(dplot_hi), std(dplot_hi)/sqrt(size(dplot_hi,1)),'lineprops',{'-','Color',cmp(2,:),'MarkerFaceColor',cmp(2,:)});
    
    
    xlim([1 11])
    set(gca,'TickDir','out'); set(gca,'TickLength',[0.03, 2])
    box off; axis square; set(gca,'fontsize',8)
    
    
    
    hleg = legend([h1.mainLine,h2.mainLine],'NH','HI');
    hleg.Box = 'off';
    ylim([0 0.2])
    xlabel('Frequency (Hz)')
    ylabel({'Encoding accuracy','(averaged over all scalp electrodes)'})
    title(conditions{cc},'FontWeight','Normal')
end


cd(fullfile(fileparts(which('initdir.m'))))
print(fullfile(pwd,'reports','review','review01','fig06','r0106.pdf'),'-dpdf')


end

