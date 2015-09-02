Z_Constants;
addpath ./scripts;

warning ('currently excluding 38e116');
SCODES(strcmp(SIDS, '38e116')) = [];
SIDS(strcmp(SIDS, '38e116')) = [];

%% make the performance plot

figure

subs = [];
hitrates = [];
chance95 = [];
ntrials = [];

for c = 1:length(SIDS);
    subjid = SIDS{c};
    
    [~, odir] = filesForSubjid(subjid);
    load(fullfile(META_DIR, [subjid '_epochs.mat']), 'tgts', 'ress', 'src_files', 'bad_marker');
    good_trials = ~all(bad_marker);
    
    [~,~,fileIndices] = unique(src_files);

    hitrates(c) = mean(tgts(good_trials)==ress(good_trials));
    [~, chance95(c)] = chanceBinom(.5, length(tgts(good_trials)));
    ntrials(c) = length(tgts(good_trials));
end


h = bar(hitrates, 'facecolor', [.75 .75 .75]);
% legendOff(h);
hold on;

x = .25:.25:(length(chance95)+.75);
plot(x, 0.5*ones(length(x),1), 'k', 'linew', 2);

for c = 1:length(chance95)
    plot((-.5:.25:.5)+c, chance95(c)*(ones(1,5)), 'k:', 'linew', 2);
end
% legendOff(ax(2:end));

% ax = hline(.7059, 'k:'); set(ax, 'linewidth', 2); % These values are generated from Z_ChancePerformance.m

legend('Performance','Chance', '95% CI','location','southeast');
ylabel('Percent correct', 'FontSize', 18);
xlabel('Subject', 'FontSize', 18);
title('Individual task performance', 'FontSize', 18);

set(gca, 'xlim', [0 length(hitrates)+1]);

labs = {};
for c = 1:length(hitrates)
    labs{end+1} = ['S' num2str(c)];
end
set(gca,'xticklabel', labs);

% 
SaveFig(OUTPUT_DIR, 'task_performance', 'png', '-r300');
SaveFig(OUTPUT_DIR, 'task_performance', 'eps', '-r600');

%% some stats
mean(hitrates)
std(hitrates)
min(hitrates)
max(hitrates)

