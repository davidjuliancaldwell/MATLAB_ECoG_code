function [accs, gammas, cs, estimates, posteriors, featureRanks] = mFancyTrainValTestSVM(data, labels, partition, ignore, featureType, extractionMethods)
    % features is MxN
    % labels   is 1xN
    % n is crossval count
    
    %% determine the partitions
    if (length(unique(partition)) < 3)
        error('must be at least three partitions');
    end
    
    if (size(data, 2) < length(unique(partition)))
        error('too few observations for the number of folds specified');
    end
    
    %% per each fold, determine the features to be used
    params.MAX_FEATS = 10;

    cs = [];
    gammas = [];
    accs = [];
    cvaccs = {};
    
    folds = unique(partition);
    
    for te = 1:length(folds)
        tei = ismember(partition, folds(te));
        [~, gammas(te), cs(te)] = mFancyCrossvalSVM(data(:, ~tei, :, :), labels(~tei), partition(~tei), params, ignore, featureType, extractionMethods);

        features = zeros(size(data, 1)*size(data, 3), size(data, 2));
        
        for feati = 1:size(data, 1)
            h = extractionMethods{featureType(feati)};
            
            ch = (1:size(data, 3)) + (feati-1)*size(data, 3);
            features(ch, :) = h(squeeze(data(feati, :, :, :)), labels, ~tei)';
        end
        
        [trFeatures, teFeatures, trLabels, teLabels, featureRanks{te}] = ...
            mrGoalFeatureSelection(features, labels, partition == folds(te), ignore);

        svm = libsvmtrain(double(trLabels), trFeatures', sprintf('-q -b 1 -g %f -c %f', gammas(te), cs(te)));
        [labelHat, ~, probs] = libsvmpredict(double(teLabels), teFeatures', svm, '-q -b 1');                
        
        % report testing accuracy
        accs(te) = mean(labelHat == teLabels);
        
        % report the inferred labels
        estimates(tei) = labelHat;
        
        % report the posterior probabilities of classification
        posteriors(tei) = max(probs');
    end    
end