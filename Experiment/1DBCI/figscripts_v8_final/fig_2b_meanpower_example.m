%% analysis looking at power changes in control electrode on subject by
%% subject basis

% common across all remote areas analysis scripts
fig_setup;
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
    
%     smoothUpStd = runningSD(epochZs(controlChannel, targetCodes == up), 10);
%     smoothDownStd = runningSD(epochZs(controlChannel, targetCodes == down), 10);
    
    ups = find(targetCodes == up);
    downs = find(targetCodes == down);

    figure;
    plot(ups, epochZs(controlChannel, targetCodes == up), 'LineStyle', 'none', 'Marker', '.', 'Color', theme_colors(red,:), 'MarkerSize', 15); hold on;
    upmu = mean(squeeze(epochZs(controlChannel, targetCodes == up)));
    
%     plot(ups, smoothUp, 'Color', theme_colors(red,:), 'LineWidth', 4); hold on;
%     plot(ups, smoothUp+smoothUpStd, 'r:', 'LineWidth', 2);
%     plot(ups, smoothUp-smoothUpStd, 'r:', 'LineWidth', 2);
    
    plot(downs, epochZs(controlChannel, targetCodes == down), 'LineStyle', 'none', 'Marker', '.', 'Color', theme_colors(blue,:), 'MarkerSize', 15); hold on;
    downmu = mean(squeeze(epochZs(controlChannel, targetCodes == down)));
%     plot(downs, smoothDown, 'Color', theme_colors(blue,:), 'LineWidth', 4);
%     plot(downs, smoothDown+smoothDownStd, 'b:', 'LineWidth', 2);
%     plot(downs, smoothDown-smoothDownStd, 'b:', 'LineWidth', 2);
    
    axis tight;
    
    plot(xlim, [upmu upmu], 'Color', theme_colors(red,:), 'LineWidth', 4);
    plot(xlim, [downmu downmu], 'Color', theme_colors(blue,:), 'LineWidth', 4);
    
%     plot([div, div], ylim, 'k', 'LineWidth', 4);
    plot(xlim, [-1 -1], 'Color', theme_colors(7,:), 'LineWidth', 1);
    plot(xlim, [0 0], 'Color', theme_colors(7,:), 'LineWidth', 4);
    plot(xlim, [1 1], 'Color', theme_colors(7,:), 'LineWidth', 1);
    plot(xlim, [2 2], 'Color', theme_colors(7,:), 'LineWidth', 1);
    plot(xlim, [3 3], 'Color', theme_colors(7,:), 'LineWidth', 1);
    
    axis off;
    set(gcf, 'Color', [1 1 1]);
    
%     title(subjids{c});
%     xlabel('trial');
%     ylabel('z(log(HG^2))');
    
    SaveFig(figOutDir, 'meanpower_example', 'eps', '-r900');
    
%     hgsave(fullfile(pwd, 'figs', ['prepostctl.' subjids{c} '.fig']));
%     SaveFig(fullfile(pwd, 'figs'), ['prepostctl.' subjids{c} '.sm']);
%     maximize;
%     SaveFig(fullfile(pwd, 'figs'), ['prepostctl.' subjids{c} '.lg']);
    % end OPTION 1
 
end


