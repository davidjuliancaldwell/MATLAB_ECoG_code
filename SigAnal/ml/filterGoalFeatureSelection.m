function kfeatures = filterGoalFeatureSelection(features, labels)
error 'not working'
% function kfeatures = mrFeatureSelection(features)
%   features is FxNxT, F being feature count N being obs count and T being
%   time
%   labels is 1xN | Nx1

% make sure to eliminate all bad channels before and to reshape the feature
% vector to be 3d

    % constants
    MAX_P = 0.05;
    MAX_N = 10;

    ulabels = unique(labels);
    filters = zeros(size(features, 1), length(ulabels), size(features, 3));
    
    % build the pattern match features
    for ulabeli = 1:length(ulabels)
        filters(:, ulabeli, :) = mean(features(:, labels==ulabels(ulabeli), :), 2);
    end
    
    % now for each observation, project each feature against the filters
    % for the possible label values, if there are 2 possible label values,
    % then the number of features we have now doubles, etc.
    
    % filters is FxLxT
    % features is FxOxT
    % nfeatures is (L*F)xO
    
    % pseudocode
    %  for each observation
    %    project all features against their corresponding L filters
    
    nfeatures = zeros(size(features, 1) * length(ulabels), size(features, 2));
    
    ofeats = zeros(size(features, 1), size(filters, 2), size(features, 3));
    
    for obsi = 1:size(features, 2)
        ofeats(:, 1, :) = features(:, obsi, :);
        ofeats(:, 2, :) = features(:, obsi, :);
        
        mdot = dot(filters, ofeats, 3);
        nfeatures(:, obsi) = mdot(:);
    end; clear obsi mdot ofeats
    
    % now select the ones that are the most statistically meaningful
    [~, p] = corr(nfeatures, labels);
    
    [sp, ki] = sort(p, 'ascend');
    
    firstLoser = find(sp > MAX_P, 1, 'first');
    
    if (isempty(firstLoser)) % everyone is below the threshold
        firstLoser = length(sp)+1;
    end
    
    firstLoser = min(firstLoser, MAX_N+1);
    
    ki(firstLoser:end) = [];

    kfeatures = features(ki, :);
end