function acc = nFoldCrossValidation(data, class, foldCount)
    % rows in data correspond to observations
    % class should be a vector equal in length to the number of rows in
    % data
    % foldCount should be less than number of rows in data, ideally much
    % less
    
    if (size(data, 1) ~= length(class))
        error('follow instructions.');
    end
   
    foldAccs = zeros(foldCount, 1);
    
    for fold = 1:foldCount
        trainIdxBool = buildFold(size(data, 1), fold, foldCount);
        trainData = data(trainIdxBool, :);
        trainClass = class(trainIdxBool);
        
        testData = data(~trainIdxBool, :);
        testClass = class(~trainIdxBool);       
        
        foldAccs(fold) = doFold(trainData, trainClass, testData, testClass);
    end
    
    acc = mean(foldAccs);
end

function bools = buildFold(dataLength, fold, foldCount)
    bools = ones(dataLength, 1);
    
    stepSize = ceil(dataLength/foldCount);
    
    start = stepSize*(fold-1)+1;
    stop = min(stepSize*fold, dataLength);
    
    bools(start:stop) = 0;
    bools = bools == 1;
end

function acc = doFold(td, tc, xd, xc)
%     [a, b] = unique(tc, 'first');
%     sorted = sortrows([b a]);
% 
%     for cz = sorted(:, 2)'
%         pr(find(cz==sorted(:,2)')) = sum(tc==cz);
%     end
%     
%     cc = classify(xd, td, tc, 'linear', pr);
    cc = classify(xd, td, tc, 'linear');

    acc = sum(cc==xc)/length(xc);
    
end