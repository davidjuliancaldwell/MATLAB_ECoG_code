%%
Z_Constants;
N_FOLDS = 10;

PRE_RT_SEC = .5;
FB_RT_SEC = .5;

% determine codepath
DELETE_META = false;
REDO_FOLDS = false;
REDO_CLASSIFICATION = true;
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

    %% do classification analyses based on feature sets
    if (REDO_CLASSIFICATION)        
        fprintf(' performing classification analyses: '); tic;
        
        load(ifile, 'epochs', 'tgts', 't', 'fbDur', 'preDur', 'bads', 'cchan');        
        labels = tgts == 1;
        
        pre = epochs(:, :, :, t > -preDur & t <= 0);
        fb  = epochs(:, :, :, t > 0 & t <= fbDur);
        all = epochs(:, :, :, t > -preDur & t <= fbDur);
        
        accuracies = zeros(4, N_FOLDS);
        estimates = cell(3, 1);
        posteriors = cell(3, 1);
        
        [accuracies(1, :), gammas{1}, cs{1}, estimates{1}, posteriors{1}, featureRanks{1}] = ...
            mFancyTrainValTestSVM(pre, labels, fold, bads, BAND_TYPE, {@epochAvFeatExtract, @timeseriesFeatExtract});
        [accuracies(2, :), gammas{2}, cs{3}, estimates{2}, posteriors{2}, featureRanks{2}] = ...
            mFancyTrainValTestSVM(fb,  labels, fold, union(bads, cchan), BAND_TYPE, {@epochAvFeatExtract, @timeseriesFeatExtract});
        [accuracies(3, :), gammas{3}, cs{3}, estimates{3}, posteriors{3}, featureRanks{3}] = ...
            mFancyTrainValTestSVM(all,  labels, fold, union(bads, cchan), BAND_TYPE, {@epochAvFeatExtract, @timeseriesFeatExtract});

        load(ifile, 'tgts', 'ress');                
        accuracies(4, :) = repmat(mean(tgts==ress), 1, N_FOLDS);
        
%         if (exist(ofile, 'file'))
%             save(ofile, '-append', 'accuracies', 'gammas', 'cs', 'estimates', 'posteriors', 'featureRanks');
%         else
%             save(ofile, 'accuracies', 'gammas', 'cs', 'estimates', 'posteriors', 'featureRanks');
%         end                    
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
        
        s_accuracies(sIdx, 1) = mean(double(labels)==estimates{1}');
        s_accuracies(sIdx, 2) = mean(double(labels)==estimates{2}');
        s_accuracies(sIdx, 3) = mean(double(labels)==estimates{3}');
        s_accuracies(sIdx, 4) = mean(tgts==ress);

        s_featureRanks{sIdx} = featureRanks;
        
        s_trials(sIdx) = length(tgts);
    end
end

%%
if (REDO_FIGURES)
    figure
    bar(s_accuracies(:,1:4));
    
    ylabel('Accuracy');
    xlabel('Subject');
    title(sprintf('Individual classification results (%d fold x-val)', N_FOLDS));

    chance = [];
    
    for c = 1:length(s_trials)
        [~, chance(c)] = chanceBinom(.5, s_trials(c));
        
        hold on;
        x = (-.4:.1:.4) + c;
        y = chance(c) * ones(size(x));

        plot(x, y, 'k:', 'linew', 3);
    end

    legend('pre','fb','both','behavioral','chance', 'location', 'southeast');
    
    SaveFig(OUTPUT_DIR, 'classification', 'png', '-r600');

    % look at relationships b/w class perf and actual perf    
    figure
    for grp = {{1, 'Pre classification performance'},{2, 'FB classification performance'},{3, 'All classification performance'}}        
        subplot(1,3,grp{1}{1});
        plot([.4 1], [.4 1], 'k:', 'linew', 2);
        hold on;
        
        f = scatter(s_accuracies(:,grp{1}{1}), s_accuracies(:,4), 'o', 'sizedata', 120, 'markerfacecolor', 'w');
        for si = 1:size(s_accuracies,1)
            ax = text(s_accuracies(si, grp{1}{1}), s_accuracies(si, 4), num2str(si));
            set(ax, 'fontsize', 8);
            set(ax, 'horizontalalignment', 'center');
        end
        hold on;
        
        xlabel(grp{1}{2});
        ylabel('Pehavioral performance');
        xlim([0.4 1]);
        ylim([0.4 1]);
        
        set(gcf,'pos', [ 28         474        1862         504]);        
    end    
    
    SaveFig(OUTPUT_DIR, 'classification_breakdown', 'png', '-r600');

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
