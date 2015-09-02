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
    
    if (~exist('params', 'var') || ~isfield(params, 'SELECT'))
        params.SELECT = 'mrmr';
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
        switch (params.SELECT)
            case 'mrmr'
                % MR feature selection
                [featureSets{i, 1}, featureSets{i, 2}, labelSets{i, 1}, labelSets{i, 2}] = ...
                    mrmrGoalFeatureSelection(features, labels, teIdx, ignore);
            case 'mr'
                % MR feature selection
                [featureSets{i, 1}, featureSets{i, 2}, labelSets{i, 1}, labelSets{i, 2}] = ...
                    mrGoalFeatureSelection(features, labels, teIdx, ignore);
            otherwise
                error('unknown feature selection type');
        end
        
    end    
    
    % do parameter sweep
    [accs, estimates, posteriors] = multiLDA(featureSets, labelSets);
end

