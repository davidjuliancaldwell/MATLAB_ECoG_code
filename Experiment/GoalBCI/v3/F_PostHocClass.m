%% Constants
addpath ./functions
Z_Constants;

%%% do post-hoc classification analyses
%% (1) extract features
allFeatures = cell(length(SIDS), 1);
allLabels = cell(length(SIDS), 1);

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
    
end

%% (2) cross-val model training

accs = {};
gammas = {};
cs = {};
estimates = {};
posteriors = {};
featureRanks = {};

for idx = 1:length(SIDS)
    labels = ~ismember(allLabels{idx}, DOWN);
    features = allFeatures{idx};
    
    partition = goal_determineFolds(labels, 5);
    
    tic
    [accs{idx}, gammas{idx}, cs{idx}, estimates{idx}, posteriors{idx}, featureRanks{idx}] = ...
        mTrainValTestSVM(features, labels, partition, find(any(isnan(features),2)));
    toc    

%     tic
%     params.SELECT = 'mrmr';
%     [accs{idx}, estimates{idx}, posteriors{idx}] = ...
%         mCrossvalLDA(features, labels, partition, params, find(any(isnan(features),2)));
%     
%     estimates{idx} = estimates{idx}';
%     posteriors{idx} = posteriors{idx}';
%     toc    

end

%% 

save(fullfile(META_DIR, 'post-hoc-classification.mat'), ...
    'allFeatures', 'allLabels', 'accs', 'gammas', 'cs', 'estimates', 'posteriors', 'featureRanks');

%% print out a summary

avg = [];
mu = [];
vr = [];

for idx = 1:length(SIDS)
    avg(idx) = mean(~ismember(allLabels{idx}, DOWN) == estimates{idx});
    [mu(idx), vr(idx)] = binostat(length(estimates{idx}), mean(~ismember(allLabels{idx}, DOWN)));
    mu(idx) = mu(idx) / length(estimates{idx});
    vr(idx) = sqrt(vr(idx)) / length(estimates{idx});
end


bar(avg, 'facecolor', [.5 .5 .5])
xlabel('Subject');
ylabel('Classification accuracy');
title('Post-hoc classification of intent using pre-trial HG');

hold on;
for idx = 1:length(SIDS)
    plot(idx + [-.25 .25], [mu(idx) mu(idx)], 'k');
    plot(idx + [-.25 .25], [mu(idx) mu(idx)]+2*vr(idx), 'k:');
    plot(idx + [-.25 .25], [mu(idx) mu(idx)]-2*vr(idx), 'k:');
end
hold off;

legend('actual', 'chance', '2 STD');

SaveFig(OUTPUT_DIR, 'ph class all', 'png', '-r300');
SaveFig(OUTPUT_DIR, 'ph class all', 'eps', '-r300');

%% now look at which features mattered

keeps = find(avg > mu + 2*vr);

for sidx = keeps
    [r2,p] = corr(allFeatures{sidx}', ~ismember(allLabels{sidx}, DOWN)');
    [~, p] = fdr(p, 0.05) 
    
    r2 = r2.^2;
    r2(~p) = NaN;
    
    load(fullfile(META_DIR, sprintf('%s-epochs.mat', SIDS{sidx})), 'montage');
    figure
    PlotDots(SIDS{sidx}, montage.MontageTokenized, r2, 'r', [-max(r2) max(r2)], 20, 'recon_colormap');
    colorbar
    load('recon_colormap');
    colormap(cm);
    maximize;
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