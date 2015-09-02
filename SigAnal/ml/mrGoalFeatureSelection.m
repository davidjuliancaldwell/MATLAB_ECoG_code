function [trf, tef, trl, tel, order] = mrGoalFeatureSelection(data, labels, istest, ignore)
    % constants
    MAX_P = 0.05;
    MAX_N = 10;

%     % collapse across time
    features = mean(data, 3);
        
    % normalize based on training data
    muTr = mean(features(:, ~istest), 2);
    stdTr = std(features(:, ~istest), [], 2);

    nfeatures = bsxfun(@minus, features, muTr);
    nfeatures = bsxfun(@rdivide, nfeatures, stdTr);

    [~, p] = corr(nfeatures(:, ~istest)', double(labels(~istest))');

%     p = zeros(size(nfeatures, 1), 1);
%     for feati = 1:size(nfeatures, 1)
%         [~, p(feati)] = corr(nfeatures(feati, ~istest)', double(labels(~istest)));
%     end    
    
    p(ignore) = 1;
    
    [sp, order] = sort(p, 'ascend');
    
    if (sp(1) > MAX_P)
        warning ('no suitable features found, keeping the best 3');
        firstLoser = 4;
    else
        firstLoser = find(sp > MAX_P, 1, 'first');
    end
    
    if (isempty(firstLoser)) % everyone is below the threshold
        firstLoser = length(sp)+1;
    end
    
    firstLoser = min(firstLoser, MAX_N+1);
    keeps = 1:(firstLoser-1);
    
    trf = nfeatures(order(keeps), ~istest);
    tef = nfeatures(order(keeps),  istest);
    trl = labels(~istest);
    tel = labels( istest);
end