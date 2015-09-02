function [bestLag, bestPeak] = getBestLag(acorr, lags)
    asave = acorr;
    
    npeaks = length(findpeaks(acorr));
    
    sfac = 3;
    while (npeaks > 1)
        acorr = GaussianSmooth(acorr, sfac);
        npeaks = length(findpeaks(acorr));
    end
    
    [~, bestLag] = findpeaks(acorr);
    bestPeak = asave(bestLag);
    bestLag = lags(bestLag);
end