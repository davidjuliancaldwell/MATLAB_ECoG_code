Z_Constants;

addpath ./scripts;

%% make the performance plot

warning('needs updating, esp. the chance performance values');

figure

subs = [];
hitrates = [];

for c = 1:length(SIDS);
    subjid = SIDS{c};
    
    [~, odir] = filesForSubjid(subjid);
    load(fullfile(META_DIR, [subjid '_epochs']), 'tgts', 'ress', 'src_files');

    [~,~,fileIndices] = unique(src_files);

    for fileIdx = unique(fileIndices)'
        subIndices = fileIndices == fileIdx;
        subs(end+1) = c;
        hitrates(end+1) = mean(tgts(subIndices)==ress(subIndices));
    end
        
end


prettybar(hitrates, subs);
ax = hline(.5, 'k'); set(ax, 'linewidth', 2);
ax = hline(.7059, 'k:'); set(ax, 'linewidth', 2); % These values are generated from Z_ChancePerformance.m

legend(SIDS, 'location', 'eastoutside');
ylabel('Percent correct', 'FontSize', 18);
title('Individual performance averages', 'FontSize', 18);
% 
SaveFig(OUTPUT_DIR, 'task_performance', 'eps', '-r300');
