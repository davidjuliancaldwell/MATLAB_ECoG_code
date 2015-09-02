%% Constants
addpath ./functions
Z_Constants;

SIDS = SIDS(1:9);


%%% do post-hoc classification analyses
%% (1) extract features
allFeatures = cell(length(SIDS), 1);
allLabels = cell(length(SIDS), 1);
c_allLabels = cell(length(SIDS), 1);

for ctr = 1:length(SIDS)
    subjid = SIDS{ctr};
    
    load(fullfile(META_DIR, sprintf('%s-epochs.mat', subjid)), 't', 'fs', '*Dur', 'targets', 'data', 'bad_channels');
    
    % build the feature matrix
    allFeatures{ctr} = zeros(size(data));
    
    for e = 1:size(data, 2)
        temp = [data{:,e}];
        allFeatures{ctr}(:, e) = mean(temp(t > -preDur & t <= 0, :), 1);
    end
    
    allFeatures{ctr}(bad_channels,:) = NaN;
    
    % build the label matrix
    allLabels{ctr} = targets;
    c_allLabels{ctr} = shuffle(targets);
    
end

%% (2) cross-val model training

accs = {};
gammas = {};
cs = {};
estimates = {};
posteriors = {};
featureRanks = {};

%%
for idx = 1:length(SIDS)
    fprintf('working on subject %d of %d\n', idx, length(SIDS));
    
    labels = ~ismember(allLabels{idx}, DOWN);
    c_labels = ~ismember(c_allLabels{idx}, DOWN);
    features = allFeatures{idx};
    
    partition = goal_determineFolds(labels, 10);
    
    % do the actual experiment
    tic
    [accs{idx}, gammas{idx}, cs{idx}, estimates{idx}, posteriors{idx}, featureRanks{idx}] = ...
        mTrainValTestSVM(features, labels, partition, find(any(isnan(features),2)));
    toc    

    % do the control experiment
    tic
    [c_accs{idx}, c_gammas{idx}, c_cs{idx}, c_estimates{idx}, c_posteriors{idx}, c_featureRanks{idx}] = ...
        mTrainValTestSVM(features, shuffle(labels), partition, find(any(isnan(features),2)));
    toc    
end

%% 

save(fullfile(META_DIR, 'post-hoc-classification.mat'), ...
    'allFeatures',   'allLabels',   'accs',   'gammas',   'cs',   'estimates',   'posteriors',   'featureRanks', ...
                     'c_allLabels', 'c_accs', 'c_gammas', 'c_cs', 'c_estimates', 'c_posteriors', 'c_featureRanks');

%%

load(fullfile(META_DIR, 'post-hoc-classification.mat'), ...
    'allFeatures',   'allLabels',   'accs',   'gammas',   'cs',   'estimates',   'posteriors',   'featureRanks', ...
                     'c_allLabels', 'c_accs', 'c_gammas', 'c_cs', 'c_estimates', 'c_posteriors', 'c_featureRanks');

%% print out a summary

avg = [];
c_avg = [];
mu = [];
vr = [];

for idx = 1:length(SIDS)
    avg(idx) = mean(~ismember(allLabels{idx}, DOWN) == estimates{idx});
    c_avg(idx) = mean(~ismember(c_allLabels{idx}, DOWN) == c_estimates{idx});

    [mu(idx),temp] = chanceBinom(.5, length(allLabels{idx}), 1000);
    vr(idx) = temp-mu(idx);
    
%     [mu(idx), vr(idx)] = binostat(length(estimates{idx}), mean(~ismember(allLabels{idx}, DOWN)));
%     mu(idx) = mu(idx) / length(estimates{idx});
%     vr(idx) = sqrt(vr(idx)) / length(estimates{idx});
end

figure
ax = bar([avg; c_avg]');
set(ax(1), 'facecolor', [.5 .5 .5]);
set(ax(2), 'facecolor', [.8 .8 .8]);

xlabel('Subject');
ylabel('Classification accuracy');
title('Post-hoc classification of intent using pre-trial HG');

hold on;
for idx = 1:length(SIDS)
    plot(idx + [-.45 .45], [mu(idx) mu(idx)], 'k', 'linew', 2);
    plot(idx + [-.45 .45], [mu(idx) mu(idx)]+vr(idx), 'k:', 'linew', 2);
    plot(idx + [-.45 .45], [mu(idx) mu(idx)]-vr(idx), 'k:', 'linew', 2);
%     plot(idx + [-.45 .45], [mu(idx) mu(idx)]+2*vr(idx), 'k:', 'linew', 2);
%     plot(idx + [-.45 .45], [mu(idx) mu(idx)]-2*vr(idx), 'k:', 'linew', 2);
end
hold off;

legend('actual', 'control', 'chance', '95% CI');

SaveFig(OUTPUT_DIR, 'ph class all', 'png', '-r300');
SaveFig(OUTPUT_DIR, 'ph class all', 'eps', '-r300');

keeps = (avg > mu + vr);

avg
fprintf('real: %f, %f\n', mean(avg(~keeps)'), sem(avg(~keeps)'));
fprintf('fake: %f, %f\n', mean(c_avg'), sem(c_avg'));
return

%% now look at which features mattered

keeps = find(avg > mu + vr);
warning hardcoded
keeps = [4 6];

for sidx = keeps
    [r2,p] = corr(allFeatures{sidx}', ~ismember(allLabels{sidx}, DOWN)');
    [~, p] = fdr(p, 0.05) ;
    
    r2 = r2.^2;
    r2(~p) = NaN;
    
    load(fullfile(META_DIR, sprintf('%s-epochs.mat', SIDS{sidx})), 'montage');
    figure
    PlotDots(SIDS{sidx}, montage.MontageTokenized, r2, 'r', [-max(r2) max(r2)], 20, 'america');
    colorbarLabel('correlation (r^2)');
    load('america');
    colormap(cm);
%     maximize;
    SaveFig(OUTPUT_DIR, ['ph area ' SIDS{sidx}], 'png', '-r300');
    
    view(270,0)
    SaveFig(OUTPUT_DIR, ['ph area m ' SIDS{sidx}], 'png', '-r300');
    
end

% keeps = find(avg > mu + vr);
% 
% for sidx = keeps
%     ranks = [featureRanks{sidx}{:}];
%     
%     used = ranks(1:10, :);
%     frac = hist(used(:), size(ranks, 1)) / size(ranks, 2);
%     
%     load(fullfile(META_DIR, sprintf('%s-epochs.mat', SIDS{sidx})), 'montage');
%     figure
%     PlotDots(SIDS{sidx}, montage.MontageTokenized, frac, determineHemisphereOfCoverage(SIDS{sidx}), [-1 1], 20, 'recon_colormap');
%     colorbar
%     load('recon_colormap');
%     colormap(cm);
%     maximize;
%     SaveFig(OUTPUT_DIR, ['ph area ' SIDS{sidx}], 'png', '-r300');
% end