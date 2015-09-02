%%
Z_Constants;
N_FOLDS = 10;
FORCE_CHANCES = false;

%% perform analyses

acc = zeros(length(SIDS), 4, N_FOLDS); % pre, fb, both, actual
gammas = [];
cs = [];
estimates = {};
posteriors = {};

for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    
    fprintf('working on subject %s\n', sid);
    
    %% set up to work on this subject
    fprintf(' loading data: ');    
    tic
    load(fullfile(META_DIR, [sid '_epochs']), 'tgts', 'ress', 'endpoints');
    load(fullfile(META_DIR, [sid '_results']), 'pre_hg', 'fb_hg');
    toc

    labels = tgts==1;

    if(FORCE_CHANCES || ~exist(fullfile(META_DIR, 'chances.mat'), 'file'))
        fprintf(' chance performance calculation: '); tic;        
        chances(sIdx) = estimateChanceValue(length(labels), max(1-mean(labels), mean(labels)));
        toc;
    end
        
    
    %% do classification analyses based on various groupings of features    
    fprintf(' pre-feature classification: '); tic;
    [acc(sIdx, 1, :), estimates{sIdx, 1}, posteriors{sIdx, 1}] = mCrossvalLDA(pre_hg, labels', N_FOLDS); toc;
%     [hits, counts] = nFoldSVM(pre_hg, tgts, N_FOLDS, 'libsvm'); toc;
%     acc(sIdx, 1) = mean(hits ./ counts);
    fprintf(' fb-feature classification: '); tic;
    [acc(sIdx, 2, :), estimates{sIdx, 2}, posteriors{sIdx, 2}] = mCrossvalLDA(fb_hg, labels', N_FOLDS); toc;
%    [hits, counts] = nFoldSVM(fb_hg, tgts, N_FOLDS, 'libsvm'); toc;
%    acc(sIdx, 2) = mean(hits ./ counts);
    fprintf(' combined-feature classification: '); tic;
    [acc(sIdx, 3, :), estimates{sIdx, 3}, posteriors{sIdx, 3}] = mCrossvalLDA([pre_hg; fb_hg], labels', N_FOLDS); toc;
%     [hits, counts] = nFoldSVM([pre_hg; fb_hg], tgts, N_FOLDS, 'libsvm'); toc;
%     acc(sIdx, 3) = mean(hits ./ counts);    
    
    acc(sIdx, 4, :) =repmat(mean(tgts==ress), 1, N_FOLDS);
    
    data(sIdx).targetingFeatures = pre_hg;
    data(sIdx).feedbackFeatures = fb_hg;
    data(sIdx).labels = tgts;
    data(sIdx).result = ress;
    
end

if (FORCE_CHANCES || ~exist(fullfile(META_DIR, 'chances.mat'), 'file'))
    save(fullfile(META_DIR, 'chances'), 'chances');
else
    load(fullfile(META_DIR, 'chances'), 'chances');
end

%%
bar(mean(acc,3));
ylabel('Accuracy');
title(sprintf('SVM vs actual performance (%d fold x-val)', N_FOLDS));
legend('pre','fb','both','actual');

for c = 1:length(chances)
    hold on;
    x = (-.4:.1:.4) + c;
    y = chances(c) * ones(size(x));
    
    plot(x, y, 'k:', 'linew', 3);
end
SaveFig(OUTPUT_DIR, 'classification', 'png', '-r600');

%%
macc = mean(acc, 3);

figure
barweb(mean(macc, 1), sem(macc, 1));

title(sprintf('Aggregate classification performance (%d fold x-val)', N_FOLDS));
set(gca, 'xtick', []);
ylabel('Accuracy');

p = [];
for c = 1:3
    [~, p(c)] = ttest2(macc(:,c),macc(:,4));
end

ylim([-.1, 1.2]);
sigstar({{.7 1.3},{.9 1.3},{1.1 1.3}}, p);


% SaveFig(OUTPUT_DIR, 'classification_summary', 'png', '-r600');

%%

modacc = [];

ths = [.5 .5 .5 .5 .5 .5 .51 .51 .51 .51 .51];

for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    load(fullfile(META_DIR, [sid '_epochs']), 'endpoints', 'ress', 'tgts');
    
    % this should be all ones, showing the relationship between endpoints
    % and targets a high endpoint means a low cursor position on the
    % screen, zero starts in the top left corner
    % ((endpoints > .50) + 1) == ress'
    
    % we can use the posteriors to bias the 'target position', really this
    % threshold for success, or can be thought of as the proportion of the
    % screen the target takes up.
    
    % logically this is as follows, if the estimate is 0, the inferred goal
    % is down, which means the endpoint threshold will become smaller
    
    % if the estimate is 1, the inferred goal is up, which means the
    % endpoint threshold will become larger.
    
    es = estimates{sIdx,3};
    po = posteriors{sIdx,3};
    
    alpha = .25; % one corresponds to willingness to move the threshold all the way to the sideo
               % of the workspace
    th = ths(sIdx) + ((es*2)-1).*(alpha*(po-.5));
    modacc(sIdx, :) = [mean(((endpoints > th) + 1) == tgts') mean(ress==tgts)];
end
figure
plot(modacc)
