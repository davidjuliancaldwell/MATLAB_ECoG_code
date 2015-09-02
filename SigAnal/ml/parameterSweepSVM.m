function [acc, gamma, c] = parameterSweepSVM(featureSets, labelSets)
    DBG = 0;
    
    % select a broad parameter range
    cExpRange = -5:2:15;
    gExpRange = -15:2:3;

    % perform the sweep
    broadaccs = paramsweep(featureSets, labelSets, 2.^cExpRange, 2.^gExpRange);
    
    % located the best 3x3 area
    [bestrow, bestcol] = findbestregion(broadaccs);
    
    if (DBG)
        figure;
        imagesc(cExpRange, gExpRange, broadaccs');        
        xlabel('log2 (c)');
        ylabel('log2 (gamma)');
        colorbar;
    end
  
    % protect against out of bounds
    if (bestrow == 1)
        bestrow = bestrow + 1;
    elseif (bestrow == length(cExpRange))
        bestrow = bestrow - 1;
    end
    
    if (bestcol == 1)
        bestcol = bestcol + 1;
    elseif (bestcol == length(gExpRange))
        bestcol = bestcol - 1;
    end
    
    if (DBG)
        for x = -1:1
            for y = -1:1
                text(cExpRange(bestrow+x), gExpRange(bestcol+y), 'x');
            end
        end
    end
    
    % build the new subrange
    cExpSubRange = cExpRange(bestrow-1):0.5:cExpRange(bestrow+1);
    gExpSubRange = gExpRange(bestcol-1):0.5:gExpRange(bestcol+1);

    % perform the sweep
    [narrowaccs, narrowcmats] = paramsweep(featureSets, labelSets, 2.^cExpSubRange, 2.^gExpSubRange);
    
    [bestrow, bestcol] = findbestvalue(narrowaccs);
    
    acc = narrowaccs(bestrow, bestcol);
    cmat = narrowcmats{bestrow, bestcol};
    
    c = 2^cExpSubRange(bestrow);
    gamma = 2^gExpSubRange(bestcol);

    if (DBG)
        figure;
        imagesc(cExpSubRange, gExpSubRange, narrowaccs');        
        xlabel('log2 (c)');
        ylabel('log2 (gamma)');
        colorbar;
        
        text(cExpSubRange(bestrow), gExpSubRange(bestcol), 'x');
        
        figure;
        imagesc(cmat);
        colormap('gray');
    end    
end

function [accs, cmats] = paramsweep(featureSets, labelSets, cVals, gVals)
    accs = zeros(length(cVals), length(gVals));
    cmats = cell(length(cVals), length(gVals));
    
    % broad parameter sweep
    for cIdx = 1:length(cVals)
        for gIdx = 1:length(gVals)
            [accs(cIdx, gIdx), cmats{cIdx, gIdx}] = validateSVM(featureSets, labelSets, cVals(cIdx), gVals(gIdx));
        end
    end
end

function [acc, cmat] = validateSVM(featureSets, labelSets, c, gamma)
    accs = zeros(length(featureSets), 1);
    
    cs = [];
    chats = [];
    
    for sIdx = 1:length(featureSets)
        trData = featureSets{sIdx, 1}';
        teData = featureSets{sIdx, 2}';
        trLabels = labelSets{sIdx, 1}';
        teLabels = labelSets{sIdx, 2}';
        
        svm = libsvmtrain(double(trLabels), trData, sprintf('-q -b 1 -c %f -g %f', c, gamma));
        labelHat = libsvmpredict(double(teLabels), teData, svm, '-q -b 1');                
        accs(sIdx) = mean(labelHat == teLabels);
        
        cs = cat(1, cs, teLabels);
        chats = cat(1, chats, labelHat);        
    end
    acc = mean(accs);
    cmat = confusionmat(cs, chats);
    
end

function [bestrow, bestcol] = findbestregion(accs)
    smoothed = conv2(accs, ones(2), 'same');
    [bestrow, bestcol] = findbestvalue(smoothed);
end

function [bestrow, bestcol] = findbestvalue(accs)
    [rowvals, bestrows] = max(accs);
    [~, bestcol] = max(rowvals);
    bestrow = bestrows(bestcol);
end