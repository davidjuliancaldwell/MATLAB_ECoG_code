% %% collect data
tcs;

subjids = {'fc9643', '4568f4', '30052b', '9ad250', '38e116'};
subcodes = {'S1', 'S2', 'S3', 'S4', 'S5'};

% subjid = 'fc9643';
% subjid = '4568f4';
% subjid = '30052b';
% % % no longer being used % subjid = '9ad250';
% subjid = '38e116';

perf_fig = figure;
counts_fig = figure;

allCounts = zeros(length(subjids), 7); % cheating, but I know this is 7

for c = 1:length(subjids);
    subjid = subjids{c};
    subcode = subcodes{c};
    
    [~, odir] = filesForSubjid(subjid);
    load(fullfile(odir, [subjid '_epochs_clean']), 'tgts', 'ress', 'src_files');

    tgtCounts = extractTargetCountFromFilename(src_files);
    tgtTypes = unique(tgtCounts);

    fprintf('subjid: %s-%s\n', subcode, subjid);
    fprintf('  total clean trials: %d\n', length(tgts));
    fprintf('  overall hit rate: %2.1f %\n', sum(tgts==ress)*100/length(tgts));
    fprintf('  trial types run:'); fprintf(' %d', tgtTypes); fprintf('\n');
    fprintf('\n');
    
    figure(perf_fig);
    
    ratePerTgtType = zeros(size(tgtTypes));
    for d = 1:length(tgtTypes)
        is = tgtCounts==tgtTypes(d);
        ratePerTgtType(d) = sum(tgts(is)==ress(is))*100 / sum(is);
        allCounts(c, tgtTypes(d)) = sum(is);
    end
    ax = plot(tgtTypes, ratePerTgtType-.15, '.-', 'MarkerSize', 30, 'LineWidth', 3, 'Color', theme_colors(2, :));
    legendOff(ax);
    hold on;
    plot(tgtTypes, ratePerTgtType, '.-', 'MarkerSize', 30, 'LineWidth', 3, 'Color', theme_colors(c+4, :));

end

set(gca, 'FontSize', 14);

xlim([1.8 7.2]);
legend(subcodes);
xlabel('number of targets', 'FontSize', 18);
ylabel('percent correct', 'FontSize', 18);
title('Individual performance by task difficulty', 'FontSize', 18);

SaveFig(fullfile(fileparts(odir), 'figs'), 'task_performance', 'eps', '-r300');

%%
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
SaveFig(fullfile(fileparts(odir), 'figs'), 'trial_counts', 'eps', '-r300');
