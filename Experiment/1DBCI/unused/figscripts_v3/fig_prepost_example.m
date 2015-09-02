%% analysis looking at pre vs post power changes in control electrode on subject by
%% subject basis

% common across all remote areas analysis scripts
subjids = {
    '4568f4'
    };

% get theme colors
tcs;

for c = 1:length(subjids)
    [~, ~, div] = getBCIFilesForSubjid(subjids{c});
    
    load(['AllPower.m.cache\' subjids{c} '.mat']);

    up = 1;
    down = 2;

    % do stuff
    
    %OPTION 1, show when the powers separate,
    % this was determined by looking at the running standard deviation
    % and determining when the user separated up and down states
    % 'dependably'
    
    smoothUp = GaussianSmooth(epochZs(controlChannel, targetCodes == up), 10)';
    smoothDown = GaussianSmooth(epochZs(controlChannel, targetCodes == down), 10)';
    sdiffs = interpDifference(smoothUp, targetCodes == up, smoothDown, targetCodes == down);
    diffs = interpDifference(epochZs(controlChannel, targetCodes == up), targetCodes == up, ...
                             epochZs(controlChannel, targetCodes == down), targetCodes == down);
                         
%     smoothUpStd = runningSD(epochZs(controlChannel, targetCodes == up), 10);
%     smoothDownStd = runningSD(epochZs(controlChannel, targetCodes == down), 10);
    
    ups = find(targetCodes == up);
    downs = find(targetCodes == down);

    cc = (1:length(targetCodes))';
    
    figure;
    plot(ups, epochZs(controlChannel, targetCodes == up), 'LineStyle', 'none', 'Marker', '.', 'Color', theme_colors(red,:), 'MarkerSize', 15); hold on;
%     plot(ups, smoothUp, 'Color', theme_colors(red,:), 'LineWidth', 2, 'LineStyle', ':'); hold on;
    uppremu = mean(squeeze(epochZs(controlChannel, targetCodes == up & cc < div)));
    uppostmu = mean(squeeze(epochZs(controlChannel, targetCodes == up & cc >= div)));
    
    plot(downs, epochZs(controlChannel, targetCodes == down), 'LineStyle', 'none', 'Marker', '.', 'Color', theme_colors(blue,:), 'MarkerSize', 15); hold on;
%     plot(downs, smoothDown, 'Color', theme_colors(blue,:), 'LineWidth', 2, 'LineStyle', ':');
    downpremu = mean(squeeze(epochZs(controlChannel, targetCodes == down & cc < div)));
    downpostmu = mean(squeeze(epochZs(controlChannel, targetCodes == down & cc >= div)));
    
    diffspremu = mean(diffs(cc < div));
    diffspostmu = mean(diffs(cc >= div));
    
    axis tight;
    xl = xlim;
    
%     plot(xlim, [upmu upmu], 'Color', theme_colors(red,:), 'LineWidth', 4);
%     plot(xlim, [downmu downmu], 'Color', theme_colors(blue,:), 'LineWidth', 4);
    plot([xl(1) div], [uppremu uppremu], 'Color', theme_colors(red,:), 'LineWidth', 4);
    plot([div xl(2)], [uppostmu uppostmu], 'Color', theme_colors(red,:), 'LineWidth', 4);
    plot([xl(1) div], [downpremu downpremu], 'Color', theme_colors(blue,:), 'LineWidth', 4);
    plot([div xl(2)], [downpostmu downpostmu], 'Color', theme_colors(blue,:), 'LineWidth', 4);
    
    
    plot([div, div], ylim, 'k', 'LineWidth', 4);
    plot(xlim, [-1 -1], 'Color', theme_colors(7,:), 'LineWidth', 1);
    plot(xlim, [0 0], 'Color', theme_colors(7,:), 'LineWidth', 4);
    plot(xlim, [1 1], 'Color', theme_colors(7,:), 'LineWidth', 1);
    plot(xlim, [2 2], 'Color', theme_colors(7,:), 'LineWidth', 1);
    plot(xlim, [3 3], 'Color', theme_colors(7,:), 'LineWidth', 1);
    
    axis off;
    set(gcf, 'Color', [1 1 1]);
    plot(sdiffs, 'k:', 'LineWidth', 4);
    SaveFig(fullfile(pwd, 'figs'), 'prepost_example', 'eps');
%     title(subjids{c});
%     xlabel('trial');
%     ylabel('z(log(HG^2))');
    
%     hgsave(fullfile(pwd, 'figs', ['prepostctl.' subjids{c} '.fig']));
%     SaveFig(fullfile(pwd, 'figs'), ['prepostctl.' subjids{c} '.sm']);
    maximize;
%     SaveFig(fullfile(pwd, 'figs'), ['prepostctl.' subjids{c} '.lg']);
    % end OPTION 1

    %% do some histograms
    figure
    
    ax(1) = subplot(211);
    % pre ups
    hist(diffs(cc < div));
    h = findobj(gca, 'Type', 'patch');
    set(h, 'FaceColor', [.5 .5 .5], 'EdgeColor', 'none');
    xlim([-2 5]); axis off;
    hold on;
    plot([diffspremu diffspremu], ylim, 'Color', [0 0 0], 'LineWidth', 4);
    
    ax(2) = subplot(212);
    % post ups
    hist(diffs(cc >= div));
    h = findobj(gca, 'Type', 'patch');
    set(h, 'FaceColor', [.5 .5 .5], 'EdgeColor', 'none');
    xlim([-2 5]); axis off;
    hold on;
    plot([diffspostmu diffspostmu], ylim, 'Color', [0 0 0], 'LineWidth', 4);
        
%     %% do some histograms
%     figure
%     
%     ax(1) = subplot(222);
%     % pre ups
%     hist(squeeze(epochZs(controlChannel, targetCodes == up & cc < div)));
%     h = findobj(gca, 'Type', 'patch');
%     set(h, 'FaceColor', [.5 .5 .5], 'EdgeColor', 'none');
%     xlim([-2 5]); axis off;
%     hold on;
%     plot([uppremu uppremu], ylim, 'Color', theme_colors(red,:), 'LineWidth', 4);
%     
%     ax(2) = subplot(224);
%     % post ups
%     hist(squeeze(epochZs(controlChannel, targetCodes == up & cc >= div)));
%     h = findobj(gca, 'Type', 'patch');
%     set(h, 'FaceColor', [.5 .5 .5], 'EdgeColor', 'none');
%     xlim([-2 5]); axis off;
%     hold on;
%     plot([uppostmu uppostmu], ylim, 'Color', theme_colors(red,:), 'LineWidth', 4);
%     
%     ax(3) = subplot(221);
%     %pre downs
%     hist(squeeze(epochZs(controlChannel, targetCodes == down & cc < div)));
%     h = findobj(gca, 'Type', 'patch');
%     set(h, 'FaceColor', [.5 .5 .5], 'EdgeColor', 'none');
%     xlim([-2 5]); axis off;
%     hold on;
%     plot([downpremu downpremu], ylim, 'Color', theme_colors(blue,:), 'LineWidth', 4);
% 
%     ax(4) = subplot(223);
%     % post downs
%     hist(squeeze(epochZs(controlChannel, targetCodes == down & cc >= div)));
%     h = findobj(gca, 'Type', 'patch');
%     set(h, 'FaceColor', [.5 .5 .5], 'EdgeColor', 'none');
%     xlim([-2 5]); axis off;
%     hold on;
%     plot([downpostmu downpostmu], ylim, 'Color', theme_colors(blue,:), 'LineWidth', 4);
    
    set(gcf, 'Color', [1 1 1]);
    
    SaveFig(fullfile(pwd, 'figs'), 'prepost_example_bars', 'eps');
    
end


