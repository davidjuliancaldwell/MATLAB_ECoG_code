%% analysis for determining division points in the control electrode
%% by maximizing the separability of the early-late distributions

% common across all remote areas analysis scripts
fig_setup;

allHitRates = {};
allTrialsInRun = {};

for c = 1:length(subjids)
    [files, ~, div] = getBCIFilesForSubjid(subjids{c});

    hitRates = [];
    trialsInRun = [];
    
    for file = files
        fprintf('processing %s\n', file{:});
        [~,sta,~] = load_bcidat(file{:});
        [starts,ends] = getEpochs(sta.TargetCode~=0, 1, true);
        hits = sum(sta.TargetCode(ends-1)==sta.ResultCode(ends-1));
        total = length(ends);

        hitRates = cat(1, hitRates, hits/total); 
        trialsInRun = cat(1, trialsInRun, total);
    end
    
    allHitRates{c} = hitRates;
    allTrialsInRun{c} = trialsInRun;
end

%%
% fig_setup;
figure;

for c = 1:length(subjids)
    subplot(2,4,c);
    
    hitRates = allHitRates{c};
    
    plot(hitRates,  '-dk', 'LineWidth', 2);
    hold on;
    xlim([0 length(hitRates)+1]);
    highlight(gca, xlim, [0 .6471], [.8 .8 .8]);
%     plot(xlim, [0.493 0.493], ':k');
    
    ylim([0 1]);
    xlabel('runs', 'FontName', 'arial');
    ylabel('performance', 'FontName', 'arial');
    title(ids{c}, 'FontName', 'arial', 'FontSize', 12);
end
set(gcf, 'Position', [316   558   924   420]);
SaveFig(figOutDir, 'S3-performance', 'png', '-r400');

