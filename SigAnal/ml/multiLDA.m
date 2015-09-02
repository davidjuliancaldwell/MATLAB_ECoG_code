function [accs, estimates, posteriors] = multiLDA(featureSets, labelSets)
    accs = [];
    estimates = [];
    posteriors = [];
    
    for c = 1:size(featureSets,1)
        [acc, estimate, posterior] = singleLDA(featureSets{c,1}, labelSets{c,1}, featureSets{c,2}, labelSets{c, 2});
        accs(c) = acc;
        estimates = cat(1, estimates, estimate);
        posteriors = cat(1, posteriors, posterior);
    end
end

function [acc, estimates, posterior] = singleLDA(trFeatures, trLabels, teFeatures, teLabels)
    if (isrow(teLabels))
        teLabels = teLabels';
    end
    
    if (isrow(trLabels))
        trLabels = trLabels';
    end

%     svm = libsvmtrain(double(trLabels), trFeatures', '-q -b 1');
%     [estimates, ~, post] = libsvmpredict(double(teLabels), teFeatures', svm, '-q -b 1');                
    
    [estimates, ~, post] = classify(teFeatures', trFeatures', trLabels, 'quadratic');
    
    posterior = zeros(size(estimates));
    
    for c = 1:length(estimates)
        posterior(c) = max(post(c, :));
    end
    
    acc = mean(estimates == teLabels);    
end
