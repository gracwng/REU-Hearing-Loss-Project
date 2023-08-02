% this function is used to preprocess EEG data from the selective auditory
% attention experiment and visualize the effect of EOG denoising (via 
% spatial filtering) on the EEG responses. We process the
% data with and without the EOG denoising module. The output figures each
% have three panels. The top left panels show topographies of the EEG
% variance ratio before/after denoising. The top right panels show
% topographies of Pearson's correlation coefficient between EEG data
% with and without denoising. A high correlation indicates that the
% denoised data to a great extend resembles the data that was not denoised.
% The buttom panel show traces of EEG electrode responses in a single trial
% with- and without denoising.

%> history
%> 2019/08/07 updated lr, figure name and folder name

function show_effect_of_denoising(sdir,bidsdir)

if nargin < 1 || isempty(sdir);     sdir    = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/'; end
if nargin < 2 || isempty(bidsdir);  bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end



task = 'selectiveattention';

pp = {'pp_ft_reref_mastoids', ...
    'pp_ft_lowpass30_fs512', ...
    'pp_ft_resample64',...
    'pp_ft_highpass05_fs64_attention', ...
    'pp_ft_reref_bipolareog', ...
    'pp_ft_segmenttrials_attention', ...
    'pp_ft_appenddatafromsessions_attention', ...
    'pp_ft_eogdenoise'                      };


for subid = 1 : 44
    
                            
            fprintf('\n exporting data from subject %0.2i, task %s',subid,task)
            
            ldir            = fullfile(bidsdir,sprintf('sub-%0.3i',subid));
            lfname          = fullfile(ldir,'eeg',sprintf('sub-%0.3i_task-%s',subid,task));

            bids_events     = ioreadbidstsv([lfname,'_events.tsv']);
            bids_channels   = ioreadbidstsv([lfname,'_channels.tsv']);
            
            
            cfg = [];
            cfg.dataset     = [lfname,'_eeg.bdf'];
            cfg.channel     = 'all';
            dat = ft_preprocessing(cfg);
            
            dat_w_denoising     = preproc_executepipeline(pp,dat,bids_events,bids_channels);
            dat_wo_denoising    = preproc_executepipeline(pp(1:end-1),dat,bids_events,bids_channels);
            

            export_diagnostic_plots(dat_w_denoising,dat_wo_denoising,subid)
        
        
    end
    

end





















function export_diagnostic_plots(dat_w_denoising,dat_wo_denoising,subid)


close all
figure
fig = get(groot,'CurrentFigure');
set(fig, 'Units', 'centimeters')
fig.Position = [1 1 28,22];

shift = 75;
mnorm = @(x)(bsxfun(@plus,x,cumsum(repmat(shift,1,size(x,2)))));
mnorm_ticks = @(x)cumsum(repmat(shift,1,size(x,2)));

% for the time trace plot we only focus on the first trial for
% visualization purposes
tt = cat(2,dat_w_denoising.time{1});
xx_wo = cat(2,dat_wo_denoising.trial{1});
xx_w = cat(2,dat_w_denoising.trial{1});

subplot(5,2,3:10)
plot(tt,mnorm(xx_wo(1:64,:)'))
hold on
plot(tt,mnorm(xx_w(1:64,:)'),'-','Color',[0.8 0.8 0.8])

set(gca,'ytick',mnorm_ticks(xx_wo(1:64,:)'))
set(gca,'yticklabel',dat_w_denoising.label(1:64))
ylim([0 max(mnorm_ticks(dat_w_denoising.trial{1}(1:64,:)'))+shift])
xlim([tt(1) tt(end)])
xlabel('Time (s)')
ylabel('Electrodes')
title('Electrode traces with- (gray) and without (coloured) denoising','FontWeight','Normal')

for ss = 1 : 2
    
    if ss == 1
        dplot = 20*log10(rms(cat(2,dat_w_denoising.trial{:})')./rms(cat(2,dat_wo_denoising.trial{:})'));
        cl = [-5 5];
        tit = {'20*log10 RMS_{with denoising}/RMS_{without denoising} '};
    else
        dplot = estcorr(cat(2,dat_w_denoising.trial{:})',cat(2,dat_wo_denoising.trial{:})');
        cl = [-1 1];
        tit = {'Correlation between responses before/after denoising'};
    end
    
    dplot = dplot(1:64);

    subplot(5,2,ss)
    load('rdbu.mat')
    colormap(cmap);
    cfg=[];
    cfg.layout='biosemi64.lay';
    layout=ft_prepare_layout(cfg);
    
    ft_plot_topo(layout.pos(1:numel(dplot),1), layout.pos(1:numel(dplot),2), dplot',...
        'mask', layout.mask,...
        'outline', layout.outline, ...
        'interplim', 'mask','isolines',3,'style','imsatiso','clim',cl);
    axis square; axis off;
    colorbar
    title(tit,'FontWeight','Normal')
end

cd(fullfile(fileparts(which('initdir.m')),'reports','dataset','figure_effect_of_denoising'))
print(sprintf('figure-effect_of_denoising--sub-%0.2i.png',subid),'-dpng','-r300')
close all
end