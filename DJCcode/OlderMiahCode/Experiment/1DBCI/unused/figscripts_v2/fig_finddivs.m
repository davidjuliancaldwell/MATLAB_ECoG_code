%% analysis for determining division points in the control electrode
%% by maximizing the separability of the early-late distributions

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
    [~, ~, olddivs(c)] = getBCIFilesForSubjid(subjids{c});
    
    load(['AllPower.m.cache\' subjids{c} '.mat']);

    up = 1;
    down = 2;

    ups = epochZs(controlChannel, targetCodes == up);
    dns = epochZs(controlChannel, targetCodes == down);
    
    ups = GaussianSmooth(ups, 10);
    dns = GaussianSmooth(dns, 10);
    
    diffs = interpDifference(ups, targetCodes == up, dns, targetCodes == down);

    figure;
    subplot(211);
    plot(diffs, 'k'); hold on;
    plot(find(targetCodes == up), ups, 'r');
    plot(find(targetCodes == down), dns, 'b');
    
    title(subjids{c});
    
    rsas = zeros(size(diffs));
    
    for d = 1:(length(diffs)-1)
        early = diffs(1:d);
        late = diffs(d+1:end);
        rsas(d) = signedSquaredXCorrValue(late, early);
    end

    rsas(end) = min(rsas(1:(end-1))); % we want to ignore this trivial solution
    
    newdivs(c) = find(max(rsas) == rsas);
    
    subplot(212);
    plot(rsas);
    
%     smoothUp = GaussianSmooth(epochZs(controlChannel, targetCodes == up), 10)';
%     smoothDown = GaussianSmooth(epochZs(controlChannel, targetCodes == down), 10)';
%     
%     smoothUpStd = runningSD(epochZs(controlChannel, targetCodes == up), 10);
%     smoothDownStd = runningSD(epochZs(controlChannel, targetCodes == down), 10);
%     
%     ups = find(targetCodes == up);
%     downs = find(targetCodes == down);

%     figure;
%     plot(ups, epochZs(controlChannel, targetCodes == up), 'r.', 'MarkerSize', 15); hold on;
%     plot(ups, smoothUp, 'r', 'LineWidth', 2); hold on;
%     plot(ups, smoothUp+smoothUpStd, 'r:', 'LineWidth', 2);
%     plot(ups, smoothUp-smoothUpStd, 'r:', 'LineWidth', 2);
%     
%     plot(downs, epochZs(controlChannel, targetCodes == down), 'b.', 'MarkerSize', 15); hold on;
%     plot(downs, smoothDown, 'b', 'LineWidth', 2);
%     plot(downs, smoothDown+smoothDownStd, 'b:', 'LineWidth', 2);
%     plot(downs, smoothDown-smoothDownStd, 'b:', 'LineWidth', 2);
%     
%     axis tight;
%     
%     plot([div, div], ylim, 'k', 'LineWidth', 2);
% 
%     title(subjids{c});
%     xlabel('trial');
%     ylabel('z(log(HG^2))');
%     
% %     hgsave(fullfile(pwd, 'figs', ['prepostctl.' subjids{c} '.fig']));
% %     SaveFig(fullfile(pwd, 'figs'), ['prepostctl.' subjids{c} '.sm']);
% %     maximize;
% %     SaveFig(fullfile(pwd, 'figs'), ['prepostctl.' subjids{c} '.lg']);
%     % end OPTION 1
 
end

[olddivs; newdivs]
