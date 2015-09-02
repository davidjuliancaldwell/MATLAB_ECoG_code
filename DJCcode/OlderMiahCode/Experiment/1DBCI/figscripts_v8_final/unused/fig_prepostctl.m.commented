%% analysis looking at power changes in control electrode on subject by
%% subject basis

% common across all remote areas analysis scripts
subjids = {
    '26cb98'
    '04b3d5'
    '38e116'
    '4568f4'
    '30052b'
    'fc9643'
    'mg'
    };

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
    
    smoothUpStd = runningSD(epochZs(controlChannel, targetCodes == up), 10);
    smoothDownStd = runningSD(epochZs(controlChannel, targetCodes == down), 10);
    
    ups = find(targetCodes == up);
    downs = find(targetCodes == down);

    figure;
    plot(ups, epochZs(controlChannel, targetCodes == up), 'r.', 'MarkerSize', 15); hold on;
    plot(ups, smoothUp, 'r', 'LineWidth', 2); hold on;
    plot(ups, smoothUp+smoothUpStd, 'r:', 'LineWidth', 2);
    plot(ups, smoothUp-smoothUpStd, 'r:', 'LineWidth', 2);
    
    plot(downs, epochZs(controlChannel, targetCodes == down), 'b.', 'MarkerSize', 15); hold on;
    plot(downs, smoothDown, 'b', 'LineWidth', 2);
    plot(downs, smoothDown+smoothDownStd, 'b:', 'LineWidth', 2);
    plot(downs, smoothDown-smoothDownStd, 'b:', 'LineWidth', 2);
    
    axis tight;
    
    plot([div, div], ylim, 'k', 'LineWidth', 2);

    title(subjids{c});
    xlabel('trial');
    ylabel('z(log(HG^2))');
    
%     hgsave(fullfile(pwd, 'figs', ['prepostctl.' subjids{c} '.fig']));
%     SaveFig(fullfile(pwd, 'figs'), ['prepostctl.' subjids{c} '.sm']);
%     maximize;
%     SaveFig(fullfile(pwd, 'figs'), ['prepostctl.' subjids{c} '.lg']);
    % end OPTION 1
 
end


