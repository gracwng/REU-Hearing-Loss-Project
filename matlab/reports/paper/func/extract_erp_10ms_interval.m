%extracts scalp maps of each patient at 10ms intervals from 0 - 400 ms

function dtab = extract_erp_10ms_interval(sdir, bidsdir, pipeline_erp, doplot)

    if nargin < 1 || isempty(sdir)
        sdir = '/mrhome/sorenaf/datasets/derived/ds-eeg-nhhi/paper/';
    end

    if nargin < 2 || isempty(bidsdir)
        bidsdir = '/Users/student/Downloads/ds-eeg-snhl 2/ds-eeg-snhl';  % Modify this line with the new file path
    end

    if nargin < 4 || isempty(doplot)
        doplot = 1;
    end

    participants_tsv = ioreadbidstsv(fullfile(bidsdir, 'participants.tsv'));
    roi = [4 5 6 9 10 11 39 40 41 44 45 46 38 47];

    % Loop over all subjects
    for subid = 1:44
        % try
        % Import the data from each subject
        fprintf('\nProcessing data from su+bject %i of %i', subid, 44)
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

        % Loop through every 10 ms interval
        % time_intervals = 0.1:0.01:0.8; % Millisecond time intervals from 100 ms to 800 ms
        time_intervals = 0:0.01:0.4; % Millisecond time intervals from 0 ms to 400 ms

        num_milliseconds = numel(time_intervals);

        for idx = 1:num_milliseconds
            % Extract the topography for each 10 ms interval
            t_start = time_intervals(idx);
            t_end = t_start + 0.01; % 10 ms interval

            topo = mean(erp_subid(:, time >= t_start & time <= t_end), 2);

            % Check if topo contains any NaN values
            if any(isnan(topo))
                % Skip this time interval and move to the next one
                fprintf('\nSkipping time interval: %d ms to %d ms due to NaN values', t_start * 1000, t_end * 1000);
                continue;
            end

            % Print the current time iteration
            fprintf('\nProcessing time interval: %d ms to %d ms', t_start * 1000, t_end * 1000);

            % Print the topo values for the current interval
            fprintf('\nTopo values:');
            fprintf(' %f', topo);

            if doplot
                % Create and save the scalp map for each participant at each millisecond
                save_topographic_map(participants_tsv.participant_id{subid}, topo, roi, t_start, participants_tsv.hearing_status{subid}, 10);
            end
        end
        % catch err
        %     fprintf('\nError processing subject %i: %s', subid, err.message);
        %     continue; % Skip to the next iteration
        % end
    end

    dtab = table(participants_tsv.participant_id, participants_tsv.hearing_status);
    dtab.Properties.VariableNames = {'participant_id', 'hearing_status'};

end
% 
% function save_topographic_map(participant_id, topo, roi, millisecond, hearing_status, time_at_200ms)
%     % Create a figure and plot the topographic map
%     figure;
%     load('rdbu.mat');
%     colormap(cmap);
%     cfg = [];
%     cfg.layout = 'biosemi64.lay';
%     layout = ft_prepare_layout(cfg);
% 
%     ft_plot_topo(layout.pos(1:65, 1), layout.pos(1:65, 2), topo(1:65)', ...
%         'mask', layout.mask, ...
%         'outline', layout.outline, ...
%         'interplim', 'mask', 'isolines', 3, 'style', 'imsatiso', 'clim', [-5 5]);
% 
%     layhighlight = struct;
%     fnames = {'pos', 'width', 'height', 'label'};
%     for f = 1:length(fnames)
%         layhighlight.(fnames{f}) = layout.(fnames{f})(roi, :);
%     end
% 
%     ft_plot_lay(layhighlight, 'box', 'no', 'label', 'no', 'point', 'yes', 'pointsymbol', '.', 'pointcolor', [0 0 0], 'pointsize', 4, ...
%         'labelsize', 8);
% 
%     lineObj = findobj(gca, 'type', 'line');
%     for l = 1:length(lineObj)
%         if get(lineObj(l), 'LineWidth') > 0.5
%             set(lineObj(l), 'LineWidth', 0.5);
%         end
%     end
% 
%     axis off
%     axis equal
% 
%     cb = colorbar;
%     cb.Label.String = 'uV';
%     millisecond_str = sprintf('%03dms', millisecond * 1000);
%     title(['Millisecond: ' millisecond_str ' (' participant_id ')'], 'FontWeight', 'Normal');
%     xlabel(['Time at 200ms: ' num2str(time_at_200ms)]);
% 
%     set(gca, 'fontsize', 8);
% 
%     % Save the figure as an image file in the corresponding folder
%     if strcmp(hearing_status, 'hi')
%         save_dir = fullfile('C:\Users\student\Documents\snhl-master\reports\paper\additional', 'Hearing Impaired');
%     elseif strcmp(hearing_status, 'nh')
%         save_dir = fullfile('C:\Users\student\Documents\snhl-master\reports\paper\additional', 'Not Hearing Impaired');
%     else
%         error('Invalid hearing status: %s', hearing_status);
%     end
% 
%     if ~exist(save_dir, 'dir')
%         mkdir(save_dir);
%     end
% 
%         % millisecond_str = sprintf('%03dms', millisecond * 1000);
%         millisecond_str = sprintf('%02dms', millisecond * 1000);
% 
%     % filename = fullfile(save_dir, sprintf('topographic_map_millisecond_%03d_%s.png', millisecond, participant_id));
%     % filename = fullfile(save_dir, ['topographic_map_millisecond_' millisecond_str '_' participant_id '.png']);
% filename = fullfile(save_dir, ['topographic_map_millisecond_' millisecond_str '_' participant_id '.jpg']);
%     saveas(gcf, filename);
% end

function save_topographic_map(participant_id, topo, roi, millisecond, hearing_status, time_at_200ms)
    % Create a figure and plot the topographic map
    figure;
    load('rdbu.mat');
    colormap(cmap);
    cfg = [];
    cfg.layout = 'biosemi64.lay';
    layout = ft_prepare_layout(cfg);

    ft_plot_topolayout(.pos(1:65, 1), layout.pos(1:65, 2), topo(1:65)', ...
        'mask', layout.mask, ...
        'outline', layout.outline, ...
        'interplim', 'mask', 'isolines', 3, 'style', 'imsatiso', 'clim', [-5 5]);

    layhighlight = struct;
    fnames = {'pos', 'width', 'height', 'label'};
    for f = 1:length(fnames)
        layhighlight.(fnames{f}) = layout.(fnames{f})(roi, :);
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
    millisecond_str = sprintf('%02dms', millisecond * 1000);
    title(['Millisecond: ' millisecond_str ' (' participant_id ')'], 'FontWeight', 'Normal');

    set(gca, 'fontsize', 8);

    % Save the figure as an image file in the corresponding folder
    if strcmp(hearing_status, 'hi')
        save_dir = fullfile('C:\Users\student\Documents\snhl-master\reports\paper\additional', 'Hearing Impaired');
    elseif strcmp(hearing_status, 'nh')
        save_dir = fullfile('C:\Users\student\Documents\snhl-master\reports\paper\additional', 'Not Hearing Impaired');
    else
        error('Invalid hearing status: %s', hearing_status);
    end

    if ~exist(save_dir, 'dir')
        mkdir(save_dir);
    end

    filename = fullfile(save_dir, ['topographic_map_millisecond_' millisecond_str '_' participant_id '.png']);
    saveas(gcf, filename, 'png'); % Save as PNG format

    close; % Close the figure to avoid multiple open figures
end
