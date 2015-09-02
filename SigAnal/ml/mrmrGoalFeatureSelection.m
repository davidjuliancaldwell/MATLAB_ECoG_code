function [trf, tef, trl, tel, order] = mrmrGoalFeatureSelection(data, labels, istest, ignore)
    % constants
    MAX_N = 10;

    % collapse across time
    features = mean(data, 3);
        
    % normalize based on training data
    muTr = mean(features(:, ~istest), 2);
    stdTr = std(features(:, ~istest), [], 2);

    nfeatures = bsxfun(@minus, features, muTr);
    nfeatures = bsxfun(@rdivide, nfeatures, stdTr);

    keptFeatures = 1:size(nfeatures, 1);
    keptFeatures(ismember(keptFeatures, ignore)) = [];
    
    ki = mrmr_corrq_d(nfeatures(keptFeatures, ~istest)', labels(~istest)', MAX_N);
    
    order = keptFeatures(ki);

    trf = nfeatures(order, ~istest);
    tef = nfeatures(order,  istest);
    trl = labels(~istest);
    tel = labels( istest);
    
end


% function kfeatures = mrmrGoalFeatureSelection(data, labels, istest, ignore)
% error 'not working'
% % function kfeatures = mrmrFeatureSelection(features)
% %   features is FxNxT, F being feature count N being obs count and T being
% %   time
% %   labels is 1xN | Nx1
% 
% % make sure to eliminate all bad channels before and to reshape the feature
% % vector to be 3d
% 
%     % constant
%     N = 10;
% 
%     % collapse across time
%     features = mean(features, 3);
%     
%     ki = mrmr_corrq_d(data', labels', N);
%     kfeatures = features(ki, :);
% end