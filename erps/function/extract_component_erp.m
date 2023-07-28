% This script generates the scalp maps for the individual components of each patient's ERP.
 
 function dtab = extract_component_erp_with_subfolder(sdir, bidsdir, pipeline_erp, doplot)

if nargin < 1 || isempty(sdir);     sdir    = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/'; end
if nargin < 2 || isempty(bidsdir);  bidsdir = '/home/sorenaf/datasets/bids/ds-eeg-nhhi'; end
if nargin < 4 || isempty(doplot);   doplot  = 1; end

% import the BIDs events file which contains information about each
% participant and their hearing status (<nh> or <hi>)
participants_tsv = ioreadbidstsv(fullfile(bidsdir,'participants.tsv'));


% for the statistical analysis of the ERP we average the
% accuracies over a cluster of fronto-central electrodes. these correspond
% to the following columns in the data summaries
roi     = [4 5 6 9 10 11 39 40 41 44 45 46  38 47];

 % Time intervals for each component
    p1_interval = [0.020, 0.075];
    n1_interval = [0.075, 0.130];
    p2_interval = [0.130, 0.185];
    n2_interval = [0.161, 0.216];
    p3_interval = [0.208, 0.263];


    for subid = 1:44
        % Import the data from each subject
        fprintf('\nProcessing data from subject %i of %i', subid, 44)
        clear dat
        fname = fullfile(sdir, 'features', 'eeg', sprintf('sub-%0.3i_eeg-%s.mat', subid, pipeline_erp.sname));
        load(fname);

        % Take the data from all trials and concatenate across the third dimension
        erp_subid = mean(cat(3, dat.trial{:}), 3)';

        % Define a corresponding time vector and ensure that each vector in the
        % cell dat.time is identical
        time = dat.time{1};
        if any(sum(ismember(cat(1, dat.time{:})', unique(time))) ~= numel(unique(time)))
            error('Something is wrong!')
        end

        % Calculate the mean amplitude of the P1 component
        p1_amp(subid, 1) = mean(mean(erp_subid(time >= p1_interval(1) & time <= p1_interval(2), roi)));

        % Calculate the mean amplitude of the N1 component
        n1_amp(subid, 1) = mean(mean(erp_subid(time >= n1_interval(1) & time <= n1_interval(2), roi)));

        % Calculate the mean amplitude of the P2 component
        p2_amp(subid, 1) = mean(mean(erp_subid(time >= p2_interval(1) & time <= p2_interval(2), roi)));

        % Calculate the mean amplitude of the N2 component
        n2_amp(subid, 1) = mean(mean(erp_subid(time >= n2_interval(1) & time <= n2_interval(2), roi)));

        % Calculate the mean amplitude of the P3 component
        p3_amp(subid, 1) = mean(mean(erp_subid(time >= p3_interval(1) & time <= p3_interval(2), roi)));

        % Extract the topography for each component```matlab
        p1_topo(subid, :) = mean(erp_subid(time >= p1_interval(1) & time <= p1_interval(2), :));
        n1_topo(subid, :) = mean(erp_subid(time >= n1_interval(1) & time <= n1_interval(2), :));
        p2_topo(subid, :) = mean(erp_subid(time >= p2_interval(1) & time <= p2_interval(2), :));
        n2_topo(subid, :) = mean(erp_subid(time >= n2_interval(1) & time <= n2_interval(2), :));
        p3_topo(subid, :) = mean(erp_subid(time >= p3_interval(1) & time <= p3_interval(2), :));

        if doplot
    % Create and save the scalp map for each participant - P1 component
    save_topographic_map(participants_tsv.participant_id{subid}, p1_topo(subid, :), roi, 'P1', participants_tsv.hearing_status{subid});
    
    % Create and save the scalp map for each participant - N1 component
    save_topographic_map(participants_tsv.participant_id{subid}, n1_topo(subid, :), roi, 'N1', participants_tsv.hearing_status{subid});
    
    % Create and save the scalp map for each participant - P2 component
    save_topographic_map(participants_tsv.participant_id{subid}, p2_topo(subid, :), roi, 'P2', participants_tsv.hearing_status{subid});
    
    % Create and save the scalp map for each participant - N2 component
    save_topographic_map(participants_tsv.participant_id{subid}, n2_topo(subid, :), roi, 'N2', participants_tsv.hearing_status{subid});
    
    % Create and save the scalp map for each participant - P3 component
    save_topographic_map(participants_tsv.participant_id{subid}, p3_topo(subid, :), roi, 'P3', participants_tsv.hearing_status{subid});
end

    end

    % export <dtab> table
    dtab = table(participants_tsv.participant_id, participants_tsv.hearing_status, p1_amp, n1_amp, p2_amp, n2_amp, p3_amp);
    dtab.Properties.VariableNames = {'participant_id', 'hearing_status', 'erp_p1', 'erp_n1', 'erp_p2', 'erp_n2', 'erp_p3'};
 end

 function save_topographic_map(participant_id, topography, highlightchannels, component, hearing_status)
    % Create a figure and plot the topographic map
    figure;
    load('rdbu.mat');
    colormap(cmap);
    cfg=[];
    cfg.layout='biosemi64.lay';
    layout=ft_prepare_layout(cfg);

    ft_plot_topo(layout.pos(1:65,1), layout.pos(1:65,2), topography(1:65)',...
    'mask', layout.mask,...
    'outline', layout.outline, ...
    'interplim', 'mask','isolines',3,'style','imsatiso','clim',[-5 5]);

    layhighlight = struct;
    fnames = {'pos', 'width', 'height', 'label'};
    for f = 1 : length(fnames)
        layhighlight.(fnames{f}) = layout.(fnames{f})(highlightchannels,:);
    end
    ft_plot_lay(layhighlight, 'box', 'no', 'label', 'no', 'point', 'yes', 'pointsymbol', '.', 'pointcolor', [0 0 0], 'pointsize', 4, ...
        'labelsize', 8);

    lineObj = findobj(gca, 'type', 'line');
    for l = 1:length(lineObj)
        if get(lineObj(l), 'LineWidth') > 0.5
            set(lineObj(l), 'LineWidth', 0.5);
        end
    end

    axis off
    axis equal

    cb = colorbar;
    cb.Label.String = 'uV';
    title([component ' (' participant_id ')'], 'FontWeight', 'Normal');

    set(gca, 'fontsize', 8);

    % Save the figure as an image file in the corresponding folder
    if strcmp(hearing_status, 'hi')
        save_dir = fullfile('C:\Users\student\Documents\snhl-master\reports\paper\additional', component, 'Hearing Impaired');
    elseif strcmp(hearing_status, 'nh')
        save_dir = fullfile('C:\Users\student\Documents\snhl-master\reports\paper\additional', component, 'Not Hearing Impaired');
    else
        error('Invalid hearing status: %s', hearing_status);
    end

    if ~exist(save_dir, 'dir')
        mkdir(save_dir);
    end

    filename = fullfile(save_dir, sprintf('topographic_map_%s_component_%s.png', component, participant_id));
    saveas(gcf, filename);
end
