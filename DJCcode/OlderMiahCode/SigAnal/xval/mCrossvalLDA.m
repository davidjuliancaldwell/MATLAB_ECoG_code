function [accs, estimates, posteriors] = mCrossvalLDA(features, labels, n, params, ignore)
    % features is MxN
    % labels   is 1xN
    % n is crossval count or fold list
    
    %% hardcoded parameters
    if (~exist('params', 'var') || ~isfield(params, 'MAX_FEATS'))
        params.MAX_FEATS = 10;
    end
    
    if (~exist('params', 'var') || ~isfield(params, 'MIN_P'))
        params.MIN_P = 0.05;
    end
    
    if (~exist('ignore', 'var'))
        ignore = false(size(features, 1), 1);
    end

    if (numel(n) == 1)
        %% per each fold, determine the features to be used
        obs = 1:length(labels);
        obsPer = length(labels)/n;
        partition =  ceil(obs / obsPer);
    else
        partition = n;
    end
    
    folds = unique(partition);
    
    for i = folds
        % break up data
        trIdx = partition~=i;
        teIdx = partition==i;

        trFeatures = features(:, trIdx);
        teFeatures = features(:, teIdx);
        trLabels   = labels(trIdx);
        teLabels   = labels(teIdx);

        % perform feature selection
        % MR feature selection
        [featureSets{i, 1}, featureSets{i, 2}, labelSets{i, 1}, labelSets{i, 2}] = ...
            mrGoalFeatureSelection(features, labels, teIdx, ignore);
        
% %         % perform feature selection
% %         % MR feature selection
% % %         featureIndices = ttestBasedFeatureSelection(trFeatures, trLabels, params);
% %         % MRMR feature selection
% % %         featureIndices = mrmrFeatureSelection(trFeatures, trLabels, params);
% %         % keep all features
% % %         featureIndices = allpassFeatureSelection(trFeatures, trLabels, params);
% %         
% %         featureSets{i,1} = trFeatures(featureIndices,:);
% %         featureSets{i,2} = teFeatures(featureIndices,:);
% %         labelSets{i,1} = trLabels;
% %         labelSets{i,2} = teLabels;
    end    
    
    % do parameter sweep
    [accs, estimates, posteriors] = multiLDA(featureSets, labelSets);
end

function featureIndices = ttestBasedFeatureSelection(data, labels, params)
    % assumes labels is binary
    if (~islogical(labels))
        error('labels must be logical for ttest based feature selection');
    end
    
    [h, truep] = ttest2(data(:, labels), data(:, ~labels), 'dim', 2);            
    
    truep(isnan(truep)) = 1;
    h(isnan(h)) = 0;
    
    if (sum(h) > params.MAX_FEATS)
        [~, order] = sort(truep, 'ascend');
        order(1:params.MAX_FEATS) = [];
        h(order) = 0;
       
    end
    
    
%     nreps = 1000;
%     ps = zeros(nreps,1);
%     
%     for c = 1:nreps
%         shuffledLabels = labels(randperm(length(labels)));
%         [~, p] = ttest2(data(:, shuffledLabels), data(:, ~shuffledLabels), 'dim', 2);
%         ps(c) = min(p);
%     end
%     
%     sts = sort(ps,'descend');
%     minp = sts(ceil(0.95*nreps));
%     
%     h = truep < minp;
    
    % determine which ones are kept    
    featureIndices = find(h);
    
    if (isempty(featureIndices))
        warning('no suitable features found');
    end
end

function featureIndices = allpassFeatureSelection(data, labels, params)
    featureIndices = 1:size(data,1);
end

function featureIndices = mrmrFeatureSelection(data, labels, params)    
    featureIndices = mrmr_corrq_d(data', labels', params.MAX_FEATS);
end