%%
Z_Constants;
N_FOLDS = 10;

PRE_RT_SEC = .5;
FB_RT_SEC = .5;

% determine codepath
DELETE_META = false;
REDO_FOLDS = false;
REDO_FEATURES = false;
REDO_CLASSIFICATION = false;
REDO_FIGURES = true;

% FEATURE_SELECTOR = @mrGoalFeatureSelection;

%% perform analyses

accuracies = zeros(length(SIDS), 4, N_FOLDS); % pre, fb, both, actual

gammas = [];
cs = [];
estimates = {};
posteriors = {};

for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    scode = SCODES{sIdx};
    
    fprintf('working on subject %s\n', sid);
    
    %% set up to work on this subject
    ifile = fullfile(META_DIR, [sid '_epochs.mat']);
    ofile = fullfile(META_DIR, [sid '_classification.mat']);    

    %% delete the old meta files if requested
    if (DELETE_META)
        delete(ofile);
    end
    
    %% determine what the fold indices are
    if (REDO_FOLDS)
        fprintf(' determining folds: '); tic;
        
        load(ifile, 'tgts');
        labels = tgts==1;

        fold = goal_determineFolds(labels, N_FOLDS);
        
        if (exist(ofile, 'file'))
            save(ofile, '-append', 'fold');
        else
            save(ofile, 'fold');
        end            
    else
        fprintf(' loading previously determined folds: '); tic;        
        load(ofile, 'fold');        
    end
    
    toc;

    %% extract features for each fold - train test val approach
    
    if (REDO_FEATURES)
        fprintf(' extracting features: '); tic;

        load(ifile, 'epochs', 'tgts', 't', 'fbDur', 'preDur', 'bads', 'cchan');        
        labels = tgts == 1;
        
        pret = t > -preDur + PRE_RT_SEC & t <= 0 + FB_RT_SEC;
        fbt  = t > 0 + FB_RT_SEC & t <= fbDur;

        reshapedEpochs = reshape(...
            permute(epochs, [1 3 2 4]), ...
            [size(epochs, 1)*size(epochs, 3) size(epochs, 2) size(epochs, 4)]);
        
        isbad = false(1, size(epochs, 3));
        isbad(bads) = true;
        
        isctl = false(1, size(epochs, 3));
        isctl(cchan) = true;
        
        reshapedIsbad = repmat(isbad, [1, size(epochs, 1)])';
        reshapedIsctl = repmat(isctl, [1, size(epochs, 1)])';

        preFeatures = mean(reshapedEpochs(:, :, pret), 3);
        preIgnore   = reshapedIsbad;
        
        fbFeatures  = mean(reshapedEpochs(:, :, fbt), 3);
        fbIgnore    = reshapedIsbad | reshapedIsctl;        
        
        allFeatures = cat(1, preFeatures, fbFeatures);
        allIgnore   = cat(1, preIgnore, fbIgnore);
        
        if (exist(ofile, 'file'))
            save(ofile, '-append', '*Features', '*Ignore', 'labels');
        else
            save(ofile, '*Features', '*Ignore', 'labels');
        end                    
    else
        fprintf(' loading previously extracted features: '); tic;
        load(ofile, '*Features', '*Ignore', 'labels');
    end
    
    toc;
    
%     %% extract features for each fold - train-test approach
%     
%     if (REDO_FEATURES)
%         fprintf(' extracting features: '); tic;
% 
%         load(ifile, 'epochs', 'tgts', 't', 'fbDur', 'preDur', 'bads', 'cchan');        
%         labels = tgts == 1;
%         
%         preFeatureSet = cell(N_FOLDS, 2);
%         fbFeatureSet = cell(N_FOLDS, 2);
%         allFeatureSet = cell(N_FOLDS, 2);
%         labelSet = cell(N_FOLDS, 2);
%         allFeatureBests = cell(N_FOLDS, 1);
%         
%         reshapedEpochs = reshape(...
%             permute(epochs, [1 3 2 4]), ...
%             [size(epochs, 1)*size(epochs, 3) size(epochs, 2) size(epochs, 4)]);
%             
%         isbad = false(1, size(epochs, 3));
%         isbad(bads) = true;
%         
%         isctl = false(1, size(epochs, 3));
%         isctl(cchan) = true;
%         
%         reshapedIsbad = repmat(isbad, [1, size(epochs, 1)]);
%         reshapedIsctl = repmat(isctl, [1, size(epochs, 1)]);
%         
%         for n = 1:N_FOLDS
%             pret = t > -preDur + PRE_RT_SEC & t <= 0 + FB_RT_SEC;
%             fbt  = t > 0 + FB_RT_SEC & t <= fbDur;
%             
%             [preFeatureSet{n,1}, preFeatureSet{n,2}, ~, ~, preFeatureBests{n}] = ...
%                 FEATURE_SELECTOR(reshapedEpochs(:,:,pret), labels, fold==n, reshapedIsbad);
%             [fbFeatureSet{n,1}, fbFeatureSet{n,2}, ~, ~, fbFeatureBests{n}] = ...
%                 FEATURE_SELECTOR(reshapedEpochs(:,:,fbt     ), labels, fold==n, reshapedIsbad|reshapedIsctl);
%             [allFeatureSet{n,1}, allFeatureSet{n,2}, labelSet{n,1}, labelSet{n,2}, allFeatureBests{n}] = ...
%                 FEATURE_SELECTOR(reshapedEpochs(:,:,pret|fbt), labels, fold==n, reshapedIsbad|reshapedIsctl);
%         end
% 
%         if (exist(ofile, 'file'))
%             save(ofile, '-append', '*FeatureSet', 'labelSet', '*FeatureBests');
%         else
%             save(ofile, '*FeatureSet', 'labelSet', '*FeatureBests');
%         end                    
%     else
%         fprintf(' loading previously extracted features: '); tic;
%         load(ofile, '*FeatureSet', 'labelSet', '*FeatureBests');
%     end
%     
%     toc;

    %% do classification analyses based on feature sets
    if (REDO_CLASSIFICATION)        
        fprintf(' performing classification analyses: '); tic;
        
        accuracies = zeros(4, N_FOLDS);
        estimates = cell(3, 1);
        posteriors = cell(3, 1);
        
        [accuracies(1, :), gammas{1}, cs{1}, estimates{1}, posteriors{1}, featureRanks{1}] = mTrainValTestSVM(preFeatures, labels, fold, preIgnore);
        [accuracies(2, :), gammas{2}, cs{3}, estimates{2}, posteriors{2}, featureRanks{2}] = mTrainValTestSVM(fbFeatures,  labels, fold, fbIgnore);
        [accuracies(3, :), gammas{3}, cs{3}, estimates{3}, posteriors{3}, featureRanks{3}] = mTrainValTestSVM(allFeatures,  labels, fold, allIgnore);

        load(ifile, 'tgts', 'ress');                
        accuracies(4, :) = repmat(mean(tgts==ress), 1, N_FOLDS);
        
        if (exist(ofile, 'file'))
            save(ofile, '-append', 'accuracies', 'gammas', 'cs', 'estimates', 'posteriors', 'featureRanks');
        else
            save(ofile, 'accuracies', 'gammas', 'cs', 'estimates', 'posteriors', 'featureRanks');
        end                    
    else
        fprintf(' loading previously completed classification analyses: '); tic;
        load(ofile, 'accuracies', 'gammas', 'cs', 'estimates', 'posteriors', 'featureRanks');
    end
    toc;
    
    %% make individual figures and prepare for group figures
    if (REDO_FIGURES)
        load(ifile, 'tgts', 'ress');                
        
        % first, make the subject specific figures
        figure;
        
        subplot(141);
        prettyconfusion(tgts==1, ress==1);
        title('actual');
        
        subplot(142);
        prettyconfusion(double(labels), estimates{1}');
        title('pre');
        
        subplot(143);
        prettyconfusion(double(labels), estimates{2}');
        title('fb');

        subplot(144);
        prettyconfusion(double(labels), estimates{3}');
        title('all');
                
        set(gcf, 'position', [14 474 1894 504]);
        mtit(scode, 'xoff', 0, 'yoff', 0.015);
        
        SaveFig(OUTPUT_DIR, sprintf('conf_%s', scode), 'eps', '-r600');
        close;
        
        s_accuracies(sIdx, :, :) = accuracies;
        s_featureRanks{sIdx} = featureRanks;
    end
    
%     toc;

%     %% do classification analyses based on feature sets
%     if (REDO_CLASSIFICATION)        
%         fprintf(' performing classification analyses: '); tic;
%         
%         accuracies = zeros(4, N_FOLDS);
%         estimates = cell(N_FOLDS, 1);
%         posteriors = cell(N_FOLDS, 1);
%         
%         [accuracies(1, :), estimates{1}, posteriors{1}] = multiLDA(preFeatures, labelSet);
%         [accuracies(2, :), estimates{2}, posteriors{2}] = multiLDA(fbFeatures,  labelSet);
%         [accuracies(3, :), estimates{3}, posteriors{3}] = multiLDA(fbFeatures,  labelSet);
% 
%         load(ifile, 'tgts', 'ress');                
%         accuracies(4, :) = repmat(mean(tgts==ress), 1, N_FOLDS);
%         
%         if (exist(ofile, 'file'))
%             save(ofile, '-append', 'accuracies', 'estimates', 'posteriors');
%         else
%             save(ofile, 'accuracies', 'estimates', 'posteriors');
%         end                    
%     else
%         fprintf(' loading previously completed classification analyses: '); tic;
%         load(ofile, 'accuracies', 'estimates', 'posteriors');
%     end
%     
%     mean(accuracies, 2)
%     toc;
end


% if (FORCE_CHANCES || ~exist(fullfile(META_DIR, 'chances.mat'), 'file'))
%     save(fullfile(META_DIR, 'chances'), 'chances');
% else
%     load(fullfile(META_DIR, 'chances'), 'chances');
% end

% %%
% bar(mean(acc,3));
% ylabel('Accuracy');
% title(sprintf('SVM vs actual performance (%d fold x-val)', N_FOLDS));
% legend('pre','fb','both','actual');
% 
% for c = 1:length(chances)
%     hold on;
%     x = (-.4:.1:.4) + c;
%     y = chances(c) * ones(size(x));
%     
%     plot(x, y, 'k:', 'linew', 3);
% end
% SaveFig(OUTPUT_DIR, 'classification', 'png', '-r600');

% %%
% macc = mean(acc, 3);
% 
% figure
% barweb(mean(macc, 1), sem(macc, 1));
% 
% title(sprintf('Aggregate classification performance (%d fold x-val)', N_FOLDS));
% set(gca, 'xtick', []);
% ylabel('Accuracy');
% 
% p = [];
% for c = 1:3
%     [~, p(c)] = ttest2(macc(:,c),macc(:,4));
% end
% 
% ylim([-.1, 1.2]);
% sigstar({{.7 1.3},{.9 1.3},{1.1 1.3}}, p);


% SaveFig(OUTPUT_DIR, 'classification_summary', 'png', '-r600');

%%

% modacc = [];
% 
% ths = [.5 .5 .5 .5 .5 .5 .51 .51 .51 .51 .51];
% 
% for sIdx = 1:length(SIDS)
%     sid = SIDS{sIdx};
%     load(fullfile(META_DIR, [sid '_epochs']), 'endpoints', 'ress', 'tgts');
%     
%     % this should be all ones, showing the relationship between endpoints
%     % and targets a high endpoint means a low cursor position on the
%     % screen, zero starts in the top left corner
%     % ((endpoints > .50) + 1) == ress'
%     
%     % we can use the posteriors to bias the 'target position', really this
%     % threshold for success, or can be thought of as the proportion of the
%     % screen the target takes up.
%     
%     % logically this is as follows, if the estimate is 0, the inferred goal
%     % is down, which means the endpoint threshold will become smaller
%     
%     % if the estimate is 1, the inferred goal is up, which means the
%     % endpoint threshold will become larger.
%     
%     es = estimates{sIdx,3};
%     po = posteriors{sIdx,3};
%     
%     alpha = .25; % one corresponds to willingness to move the threshold all the way to the sideo
%                % of the workspace
%     th = ths(sIdx) + ((es*2)-1).*(alpha*(po-.5));
%     modacc(sIdx, :) = [mean(((endpoints > th) + 1) == tgts') mean(ress==tgts)];
% end
% figure
% plot(modacc)
