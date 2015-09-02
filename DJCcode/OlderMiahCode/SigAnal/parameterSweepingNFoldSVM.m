function [acc, c, gamma] = parameterSweepingNFoldSVM(features, labels, n)
    DBG = 1;
    
    % select a broad parameter range
    cExpRange = -5:2:15;
    gExpRange = -15:2:3;

    % perform the sweep
    broadaccs = paramsweep(features, labels, n, 2.^cExpRange, 2.^gExpRange);
    
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
    cExpSubRange = cExpRange(bestrow-1):0.25:cExpRange(bestrow+1);
    gExpSubRange = gExpRange(bestcol-1):0.25:gExpRange(bestcol+1);

    % perform the sweep
    narrowaccs = paramsweep(features, labels, n, 2.^cExpSubRange, 2.^gExpSubRange);
    
    [bestrow, bestcol] = findbestvalue(narrowaccs);
    
    acc = narrowaccs(bestrow, bestcol);
    c = 2^cExpSubRange(bestrow);
    gamma = 2^gExpSubRange(bestcol);

    if (DBG)
        figure;
        imagesc(cExpSubRange, gExpSubRange, narrowaccs');        
        xlabel('log2 (c)');
        ylabel('log2 (gamma)');
        colorbar;
        
        text(cExpSubRange(bestrow), gExpSubRange(bestcol), 'x');
    end    
end

function accs = paramsweep(features, labels, n, cVals, gVals)
    accs = zeros(length(cVals), length(gVals));
    
    % broad parameter sweep
    for cIdx = 1:length(cVals)
        for gIdx = 1:length(gVals)
            [hits, counts] = nFoldSVM(features, labels, n, 'libsvm', cVals(cIdx), gVals(gIdx));
            accs(cIdx, gIdx) = mean(hits./counts);
        end
    end
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