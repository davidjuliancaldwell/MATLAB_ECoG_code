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
fig_setup;
figure;

% linespecs = {'k+-','kx--','kd-.','ks:','k^-','kv--','kh-.'};
% colors = {[0 0 0], [0 0 0], [0 0 0], [0 0 0], [.5 .5 .5], [.5 .5 .5], [.5 .5 .5]};

ac = [];
prePerfs = [];
postPerfs = [];

for c = 1:length(subjids)
%     subplot(2,4,c);
    
    hitRates = allHitRates{c};
    
    prePerfs(c) = hitRates(1);
    postPerfs(c) = hitRates(end);
    
    plot(hitRates-.002, 'o-', 'Color', [0 0 0], 'MarkerSize', 3, 'LineWidth', 3);
    ac(c) = plot(hitRates, 'o-', 'Color', theme_colors(c+3,:), 'MarkerSize', 3, 'LineWidth', 3);
    
%     plot(hitRates([1 end]), 'x', 'Color', theme_colors(c+3,:), 'MarkerSize', 7, 'LineWidth', 3);
   
    hold on;
%     plot(xlim, [0.493 0.493], ':k');
    
    xlabel('Runs', 'FontName', 'arial', 'FontSize', 16);
    ylabel('Fraction of successful trials', 'FontName', 'arial', 'FontSize', 16);
%     title(ids{c}, 'FontName', 'arial', 'FontSize', 12);
    title('Individual task performance', 'FontName', 'arial', 'FontSize', 16);
    set(gca, 'FontName', 'arial', 'FontSize', 14);
end

axis tight;
xlim([0 max(xlim)+1]);
ylim([0.3 1]);

h = legend(ac, {'S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7'});
set(h, 'Location', 'Southeast');

plot(xlim, [0.6471 0.6471], 'k:', 'LineWidth', 2);
plot(xlim, [.5 .5], 'k--', 'LineWidth', 2);

% highlight(gca, xlim, [0 .6471], [.9 .9 .9]);

% set(gcf, 'Position', [316   558   924   420]);
SaveFig(figOutDir, 'S3-performance-indiv', 'eps', '-r900');

%% make the group average performance curve
len = -Inf;

for c = 1:length(subjids)
    len = max(length(allHitRates{c}), len);
end

hitRateMtx = NaN * ones(len, length(subjids));

for c = 1:length(subjids)
    hitRateMtx(1:length(allHitRates{c}), c) = allHitRates{c};
end

hitMus = nanmean(hitRateMtx, 2);
hitSigs = nanstd(hitRateMtx, 0, 2);
cnt = sum(~isnan(hitRateMtx), 2);

r = 1:6;
figure;
% errorbar(r, hitMus(r), hitSigs(r) ./ sqrt(cnt(r)));
plotWSE(r, hitRateMtx(r, :), [.5 .5 .5], .5, 'k', 2);


xlabel('Runs', 'FontName', 'arial', 'FontSize', 16);
ylabel('Fraction of successful trials', 'FontName', 'arial', 'FontSize', 16);
%     title(ids{c}, 'FontName', 'arial', 'FontSize', 12);
title('Average task performance', 'FontName', 'arial', 'FontSize', 16);
set(gca, 'FontName', 'arial', 'FontSize', 14);

ylim([0.3 1]);
hold on;
plot(xlim, [0.6471 0.6471], 'k:', 'LineWidth', 2);
plot(xlim, [.5 .5], 'k--', 'LineWidth', 2);

h = legend('group performance average', '95^{th} percentile of chance', 'chance');
set(h, 'Location', 'Southwest');

SaveFig(figOutDir, 'S3-performance', 'eps', '-r900');


%% make the bar plot
figure;

mus = [mean(prePerfs) mean(postPerfs)];
sems = [std(prePerfs) std(postPerfs)] ./ sqrt(length(prePerfs));
% barweb(mus, sems, .8, {'first run', 'last run'}', 'Performance summary', '', 'Fraction of successful trials')
dat = barweb(mus, sems, .8, {'first run              last run'}, 'Performance summary', '', 'Fraction of successful trials', [1 1 1; .5 .5 .5]);
hold on;
plot(xlim, [0.6471 0.6471], 'k:', 'LineWidth', 2);
plot(xlim, [.5 .5], 'k--', 'LineWidth', 2);

[h, p] = ttest(prePerfs, postPerfs, 0.05, 'l')

ylim([0.3 1]);

SaveFig(figOutDir, 'S3-performance-summary', 'eps', '-r900');



