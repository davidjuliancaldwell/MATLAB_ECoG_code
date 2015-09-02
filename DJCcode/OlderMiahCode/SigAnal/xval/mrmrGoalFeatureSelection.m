function kfeatures = mrmrGoalFeatureSelection(features, labels)
error 'not working'
% function kfeatures = mrmrFeatureSelection(features)
%   features is FxNxT, F being feature count N being obs count and T being
%   time
%   labels is 1xN | Nx1

% make sure to eliminate all bad channels before and to reshape the feature
% vector to be 3d

    % constant
    N = 10;

    % collapse across time
    features = mean(features, 3);
    
    ki = mrmr_corrq_d(data', labels', N);
    kfeatures = features(ki, :);
end