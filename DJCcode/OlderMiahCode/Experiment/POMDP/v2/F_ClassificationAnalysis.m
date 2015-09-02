%% SETUP
Z_Constants;
addpath ./scripts;

% determine codepath
DELETE_META = false;
REDO_FOLDS = false;
REDO_FEATURES = true;
REDO_CLASSIFICATION = true;
REDO_FIGURES = true;

atic=  tic;

%% perform analyses

accuracies = zeros(length(SIDS), 4, N_FOLDS); % pre, fb, both, actual

gammas = [];
cs = [];
estimates = {};
posteriors = {};
featureRanks = {};

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

        load(ifile, '*feats', 'tgts', 'cchan', 'bad_channels');        
%         load(ifile, 'epochs', 'tgts', 't', 'fbDur', 'preDur', 'bads_channels', 'cchan');        
        
        labels = tgts == 1;

        preFeatures = reshape(permute(prefeats, [1 3 2]), [size(prefeats, 1)*size(prefeats,3) size(prefeats, 2)]);
        fbFeatures  = reshape(permute(fbfeats, [1 3 2]), [size(fbfeats, 1)*size(fbfeats,3) size(fbfeats, 2)]);
        
        isbad = false(1, size(prefeats, 3));
        isbad(bad_channels) = true;
        
        isctl = false(1, size(prefeats, 3));
        isctl(cchan) = true;
        
        reshapedIsbad = repmat(isbad, [1, size(prefeats, 1)])';
        reshapedIsctl = repmat(isctl, [1, size(prefeats, 1)])';

        preIgnore   = reshapedIsbad;
        [preR, preP] = corr(preFeatures', labels);
                
        fbIgnore    = reshapedIsbad | reshapedIsctl;        
        [fbR, fbP] = corr(fbFeatures', labels);
        
        if (exist(ofile, 'file'))
            save(ofile, '-append', '*Features', '*Ignore', 'labels', '*R', '*P');
        else
            save(ofile, '*Features', '*Ignore', 'labels', '*R', '*P');
        end                    
    else
        fprintf(' loading previously extracted features: '); tic;
        load(ofile, '*Features', '*Ignore', 'labels', '*R', '*P');
    end
    
    toc;
    
    %% do classification analyses based on feature sets
    if (REDO_CLASSIFICATION)        
        fprintf(' performing classification analyses: '); tic;
        
        accuracies = zeros(3, N_FOLDS);
        estimates = cell(2, 1);
        posteriors = cell(2, 1);

%         [accuracies(1, :), estimates{1}, posteriors{1}] = mCrossvalLDA(preFeatures, labels, fold, struct(), preIgnore); estimates{1} = estimates{1}';        
        [accuracies(1, :), gammas{1}, cs{1}, estimates{1}, posteriors{1}, featureRanks{1}] = mTrainValTestSVM(preFeatures, labels, fold, preIgnore);
%         [accuracies(2, :), estimates{2}, posteriors{2}] = mCrossvalLDA(fbFeatures, labels, fold, struct(), fbIgnore); estimates{2} = estimates{2}';
        [accuracies(2, :), gammas{2}, cs{3}, estimates{2}, posteriors{2}, featureRanks{2}] = mTrainValTestSVM(fbFeatures,  labels, fold, fbIgnore);

        load(ifile, 'tgts', 'ress');                
        accuracies(3, :) = repmat(mean(tgts==ress), 1, N_FOLDS);
        
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
        
        subplot(131);
        prettyconfusion(tgts==1, ress==1);
        title('actual');
        
        subplot(132);
        prettyconfusion(double(labels), estimates{1}');
        title('pre');
        
        subplot(133);
        prettyconfusion(double(labels), estimates{2}');
        title('fb');
                
        set(gcf, 'position', [14 474 1894 504]);
        mtit(scode, 'xoff', 0, 'yoff', 0.015);
        
        SaveFig(OUTPUT_DIR, sprintf('conf_%s', scode), 'eps', '-r600');
        close;
        
        s_accuracies(sIdx, 1) = mean(double(labels)==estimates{1}');
        s_accuracies(sIdx, 2) = mean(double(labels)==estimates{2}');
        s_accuracies(sIdx, 3) = mean(tgts==ress);

        s_featureRanks{sIdx} = featureRanks;
        
        s_trials(sIdx) = length(tgts);
    end
end

%%
if (REDO_FIGURES)
    figure
    bar(s_accuracies(:,1:3));
    
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

    legend('pre','fb','behavioral','chance', 'location', 'southeast');
    
    SaveFig(OUTPUT_DIR, 'classification', 'png', '-r600');

    % look at relationships b/w class perf and actual perf    
    figure
    for grp = {{1, 'Pre classification performance'},{2, 'FB classification performance'}}        
        subplot(1,2,grp{1}{1});
        plot([.4 1], [.4 1], 'k:', 'linew', 2);
        hold on;
        
        f = scatter(s_accuracies(:,grp{1}{1}), s_accuracies(:,3), 'o', 'sizedata', 120, 'markerfacecolor', 'w');
        for si = 1:size(s_accuracies,1)
            ax = text(s_accuracies(si, grp{1}{1}), s_accuracies(si, 3), num2str(si));
            set(ax, 'fontsize', 8);
            set(ax, 'horizontalalignment', 'center');
        end
        hold on;
        
        xlabel(grp{1}{2});
        ylabel('Behavioral performance');
        xlim([0.4 1]);
        ylim([0.4 1]);
        
        set(gcf,'pos', [ 28         474        1462         504]);        
    end    
    
    SaveFig(OUTPUT_DIR, 'classification_breakdown', 'png', '-r600');

end

toc(atic);