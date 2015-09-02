function [acc, mx, my, mauc, msens, mspec, model] = nFoldCrossValidation(data, class, foldCount, lambda)
    % rows in data correspond to observations
    % class should be a vector equal in length to the number of rows in
    % data
    % foldCount should be less than number of rows in data, ideally much
    % less
    
    % returns roc information as well
    
    if (size(data, 1) ~= length(class))
        error('follow instructions.');
    end
    if (~exist('lambda', 'var'))
        lambda = 1;
    end
   
    foldAccs = zeros(foldCount, 1);
    
    mx = [];
    my = [];
    
    for fold = 1:foldCount
        if (foldCount > 1)
            trainIdxBool = buildFold(size(data, 1), fold, foldCount);
            trainData = data(trainIdxBool, :);
            trainClass = class(trainIdxBool);

            testData = data(~trainIdxBool, :);
            testClass = class(~trainIdxBool);       

            [~, posterior, model(fold)] = doFold(trainData, trainClass, testData, testClass, lambda);
            [mmx, mmy, T, aucs(fold)] = perfcurve(testClass, posterior, true);            
            
            if (~isempty(mx))
                while (size(mmx,1) < size(mx,1))
                    mmx(end+1) = 1;
                    mmy(end+1) = 1;
                end
                while (size(mmx,1) > size(mx,1))
                    mx(end+1,:) = 1;
                    my(end+1,:) = 1;
                end
            end
            
            
            mx(:,fold) = mmx;
            my(:,fold) = mmy;
            
            % balance the sens/spec
            foo = abs(mx(:,fold)-(1-my(:,fold)));
            pthresh = T(find(foo==min(foo),1,'first'));
            
            classhat = posterior > pthresh;
            foldAccs(fold) = mean(classhat==testClass);
            
            sens(fold) = sum((classhat == 1) & (testClass == 1)) / sum(testClass);
            spec(fold) = sum((classhat == 0) & (testClass == 0)) / sum(~testClass);            
        else
            [foldAccs, posterior, sens, spec, model] = doFold(data, class, data, class);
            [mx, my, ~, aucs] = perfcurve(class, posterior, true);
        end            
    end
    
    mx = mean(mx, 2);
    my = mean(my, 2);
    mauc = mean(aucs);
    msens = mean(sens);
    mspec = mean(spec);
    
    acc = mean(foldAccs);
end

function bools = buildFold(dataLength, fold, foldCount)
    bools = ones(dataLength, 1);

    stepSize = floor(dataLength/foldCount);

    start = stepSize*(fold-1)+1;
    stop = min(stepSize*fold, dataLength);

    bools(start:stop) = 0;
    bools = bools == 1;
end

function [acc, p, model] = doFold(td, tc, xd, xc, lambda)
%     [a, b] = unique(tc, 'first');
%     sorted = sortrows([b a]);
% 
%     for cz = sorted(:, 2)'
%         pr(find(cz==sorted(:,2)')) = sum(tc==cz);
%     end
%     
%     [cc, ~, p] = classify(xd, td, tc, 'linear', pr);

    
%     [cc, ~, p] = classify(xd, td, tc, 'linear');
%     
%     % removing the clas zero component of p for the 'classify' case
%     if (tc(1) == 0)
%         p = p(:,2);
%     else
%         p = p(:,1);
%     end

    % logistic regression with an L1 norm regularizer
    [model] = logregFit(td, tc, 'regType', 'L1', 'lambda', lambda);
    [cc, p] = logregPredict(model, xd);
    
%     cc = p > .25;
    
    acc = sum(cc==xc)/length(xc);
end