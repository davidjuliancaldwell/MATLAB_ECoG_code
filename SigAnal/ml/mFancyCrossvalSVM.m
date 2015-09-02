function [acc, gamma, c] = mFacyCrossvalSVM(data, labels, partition, params, ignore, featureType, extractionMethods)
    % features is MxN
    % labels   is 1xN
    % n is crossval count
    
    %% hardcoded parameters
    if (~exist('params', 'var') && ~isfield(params, 'MAX_FEATS'))
        params.MAX_FEATS = 10;
    end
    
    if (~exist('params', 'var') && ~isfield(params, 'MIN_P'))
        params.MIN_P = 0.05;
    end
    
    %% per each fold, determine the features to be used    
    featureSets = {};
    labelSets = {};
    
    folds = unique(partition);
    
    for i = 1:length(folds)        
        features = zeros(size(data, 1)*size(data, 3), size(data, 2));
        
        for feati = 1:size(data, 1)
            h = extractionMethods{featureType(feati)};
            
            ch = (1:size(data, 3)) + (feati-1)*size(data, 3);
            features(ch, :) = h(squeeze(data(feati, :, :, :)), labels, partition ~= folds(i))';
        end
        
        [featureSets{i, 1}, featureSets{i, 2}, labelSets{i, 1}, labelSets{i, 2}] = ...
            mrGoalFeatureSelection(features, labels, partition == folds(i), ignore);
        
%         featureIndices = mrmrFeatureSelection(trFeatures, trLabels, params);
%         
%         featureSets{i,1} = trFeatures(featureIndices,:);
%         featureSets{i,2} = teFeatures(featureIndices,:);
%         labelSets{i,1} = trLabels;
%         labelSets{i,2} = teLabels;
    end    
    
    % do parameter sweep
    [acc, gamma, c] = parameterSweepSVM(featureSets, labelSets);
end

% function featureIndices = ttestBasedFeatureSelection(data, labels, params)
%     % assumes labels is binary
%     if (~islogical(labels))
%         error('labels must be logical for ttest based feature selection');
%     end
%     
%     [~, ~, ~, t] = ttest2(data(:, labels), data(:, ~labels), 'dim', 2);        
%     truet = abs(t.tstat);
% 
%     nreps = 1000;
%     ts = zeros(nreps,1);
%     
%     for c = 1:nreps
%         shuffledLabels = labels(randperm(length(labels)));
%         [~, ~, ~, t] = ttest2(data(:, shuffledLabels), data(:, ~shuffledLabels), 'dim', 2);
%         ts(c) = max(abs(t.tstat));
%     end
%     
%     sts = sort(ts,'ascend');
%     mint = sts(ceil(0.95*nreps));
%     
%     h = truet > mint;
%     
%     % determine which ones are kept    
%     featureIndices = find(h);
%     
%     if (isempty(featureIndices))
%         warning('no suitable features found');
%     end
% end
% 
% function featureIndices = allpassFeatureSelection(data, labels, params)
%     featureIndices = 1:size(data,1);
% end
% 
% function featureIndices = mrmrFeatureSelection(data, labels, params)    
%     featureIndices = mrmr_corrq_d(data', labels', params.MAX_FEATS);
% end