function [hits, counts] = nFoldSVM(features, labels, n, svmMethod, c, gamma)
    if (~exist('svmMethod', 'var'))
        svmMethod = 'matlab';
    end
    
    if (strcmp(svmMethod, 'libsvm')==0)
        if (exist('c','var') || exist('gamma','var'))
            warning('c and gamma are not used in methods other than the libsvm impl');
        end
    end
    
    features(sum(isnan(features)') > 0, :) = [];
    
    CVO = cvpartition(length(labels),'k',n);
    hits = zeros(CVO.NumTestSets,1);
    counts = hits;
    
    for i = 1:CVO.NumTestSets
        trIdx = CVO.training(i);
        teIdx = CVO.test(i);

        switch(svmMethod)
            case 'matlab'
                % matlab svm impl                
                svm = svmtrain(features(:, trIdx), labels(trIdx), 'options', statset('MaxIter', 100000));
                cHat = svmclassify(svm, features(:, teIdx)');
            case 'libsvm'
                % libsvm svm impl
                % using RBF
                if (~exist('c','var'))
                    c = 1;
                end
                if (~exist('gamma','var'))
                    gamma = 1/size(features,1);
                end
                
                svm = libsvmtrain(double(labels(trIdx)), features(:, trIdx)', sprintf('-q -b 1 -c %f -g %f', c, gamma));
                % using linear kernel
%                 svm = libsvmtrain(double(labels(trIdx)), features(:, trIdx)', '-q -t 0 -b 1');
                [cHat, ~, prob] = libsvmpredict(double(labels(teIdx)), features(:, teIdx)', svm, '-q -b 1');                
        end        
                
        hits(i) = sum(cHat == labels(teIdx));
        counts(i) = sum(teIdx);
    end    
end