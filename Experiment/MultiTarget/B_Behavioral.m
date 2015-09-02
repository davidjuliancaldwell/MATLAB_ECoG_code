%% define constants
tcs;

META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'MultiTarget', 'meta');
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'MultiTarget', 'figures');

TouchDir(META_DIR);
TouchDir(OUTPUT_DIR);

FONT_SIZE = 20;
LEGEND_FONT_SIZE = 14;

SIDS = {'fc9643', '38e116'};
SUBCODES = {'S1', 'S2'};

%% do the performance figure

perf_fig = figure;
counts_fig = figure;
easyhard_fig = figure;

allCounts = zeros(length(SIDS), 7); % cheating, but I know the max number of targets performed by any subject/run was 7

for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};
    
    metaFile = fullfile(META_DIR, sprintf('%s.mat', subjid));
    load(metaFile);
    
    tgtTypes = unique(ntargets);
    
    fprintf('subjid: %s-%s\n', subcode, subjid);
    fprintf('  total clean trials: %d\n', length(targets));
    fprintf('  overall hit rate: %2.1f %\n', sum(targets==results)*100/length(targets));
    fprintf('  trial types run:'); fprintf(' %d', tgtTypes); fprintf('\n');
    fprintf('\n');
    
    figure(perf_fig);
    
    ratePerTgtType = zeros(size(tgtTypes));
    for d = 1:length(tgtTypes)
        is = ntargets==tgtTypes(d);
        ratePerTgtType(d) = sum(targets(is)==results(is))*100 / sum(is);
        allCounts(c, tgtTypes(d)) = sum(is);
    end
    ax = plot(tgtTypes, ratePerTgtType-.15, '.-', 'MarkerSize', 30, 'LineWidth', 3, 'Color', theme_colors(2, :));
    legendOff(ax);
    hold on;
    plot(tgtTypes, ratePerTgtType, '.-', 'MarkerSize', 30, 'LineWidth', 3, 'Color', theme_colors(c+4, :));

end

set(gca, 'FontSize', 14);

xlim([1.8 7.2]);
legend(SUBCODES);
xlabel('Number of targets', 'FontSize', 18);
ylabel('Percent correct', 'FontSize', 18);
title('Individual performance by target count', 'FontSize', 18);

SaveFig(OUTPUT_DIR, 'task_performance', 'eps', '-r300');

%% make the interior - exterior performance figure

for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};
    
    metaFile = fullfile(META_DIR, sprintf('%s.mat', subjid));
    load(metaFile);

    isInterior = targets < ntargets & targets > 1;
    isHit = targets == results;

    rate(1, c) = sum(~isInterior & isHit) / sum(~isInterior);
    rate(2, c) = sum(isInterior & isHit) / sum(isInterior);
    
    length(ntargets)
end

figure(easyhard_fig);

ax = bar(rate);

for c = 1:length(ax)
    set(ax(c), 'FaceColor', theme_colors(4+c,:));
end

set(gca, 'FontSize', 14);
ylabel('Accuracy', 'FontSize', 18);
xlabel('Difficulty', 'FontSize', 18);
title('Performance by task difficulty');

set(gca, 'XTickLabel', {'Exterior', 'Interior'});
set(gca, 'TickLength', [0 0])

legend('S1', 'S2');
SaveFig(OUTPUT_DIR, 'task_easyhard', 'eps', '-r300');

%% make the trial count figure
figure(counts_fig);

allCountsSum = sum(allCounts(:,2:end), 2);

ax = bar([allCountsSum allCounts]',1);
for c = 1:length(ax)
    set(ax(c), 'FaceColor', theme_colors(4+c,:))
end

set(gca, 'FontSize', 14);
ylabel('trials', 'FontSize', 18);
xlabel('number of targets', 'FontSize', 18);
title('Trial quantity by task difficulty');

set(gca, 'XTickLabel', {'All',' ','2','3','4','5','6','7'});
set(gca, 'TickLength', [0 0])

for c = 3:7
    vline(c+.5, 'k:');
end

title('Trial counts by task difficulty', 'FontSize', 18);
xlim([0 9]);
SaveFig(OUTPUT_DIR, 'trial_counts', 'eps', '-r300');

%% make the outcome matrices

for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};
    
    metaFile = fullfile(META_DIR, sprintf('%s.mat', subjid));
    load(metaFile);
    
    tgtTypes = unique(ntargets);
           
    for tgt = tgtTypes'
        subtargets = targets(ntargets==tgt);
        subresults = results(ntargets==tgt);
        
        mtx = zeros(tgt);

        for d = 1:length(subtargets)
            mtx(subtargets(d), subresults(d)) = mtx(subtargets(d), subresults(d)) + 1;
        end

        pmtx = bsxfun(@rdivide, mtx, sum(mtx, 2));
        
        figure;
        imagesc(pmtx);
        set(gca, 'clim', [0 1]);
        set(gca, 'xtick', 1:tgt);
        set(gca, 'ytick', 1:tgt);
        
        set(gca, 'fontsize', LEGEND_FONT_SIZE);
        ylabel('Target', 'fontsize', FONT_SIZE);
        xlabel('Result', 'fontsize', FONT_SIZE);
        colormap('gray');
        
        for x = 1:tgt
            for y = 1:tgt
                if (pmtx(x, y) < 0.5)
                    labelColor = [1 1 1];
                else
                    labelColor = [0 0 0];
                end
                
               if (pmtx(x,y) >= 0.01)
                    text(y, x, sprintf('%2.0f%%', 100*pmtx(x, y)), 'horizontalalignment', 'center', 'verticalalignment', 'middle', 'fontsize', LEGEND_FONT_SIZE, 'color', labelColor);
               end
                
            end
        end
        
        fname = sprintf('performance-matrix-S%d-%d.eps', c, tgt);
        SaveFig(OUTPUT_DIR, fname, 'eps', '-r300');
    end
end