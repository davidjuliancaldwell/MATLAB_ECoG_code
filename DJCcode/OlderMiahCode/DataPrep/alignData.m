%% alignData.m
%  jdw - 11APR2011
%
% Changelog:
%   11APR2011 - originally written
%
% This function takes two recordings recorded at arbitrarily different 
%   sampling frequencies and makes N attempts to temporally align the two 
%   recordings.  
%
% Parameters:
%   x - the first recording
%   y - the second recording
%   fsX - the sampling rate of x
%   fsY - the sampling rate of y
%   N - the number of alignment attempts to be made
%   doPlots - if true, the function will generate plots of the aligned
%     recordings (limited in size by the length of the shorter)
%   flippedPolarityOk - if true, the function will look at the absolute
%     value of the xcovariance between x and y, permitting the possibility
%     that the signals are 180 degrees out of phase.
%
% Return Values:
%   offsets - the offsets at which the data are best aligned, with respect
%     to the longer of the two data sets
%   corrs - the relative correlation values of each of the offsets returned
%

function [offsets, corrs] = alignData(x, y, fsX, fsY, N, doPlots, flippedPolarityOk)
    if (~exist('flippedPolarityOk', 'var'))
        flippedPolarityOk = false;
    end
    
%     commonFs = gcd(fsX, fsY);
%     
    commonFs = min(fsX, fsY);

    downsampleFactorX = fsX / commonFs;
    downsampleFactorY = fsY / commonFs;

    if (downsampleFactorX > 10)
        warning('downsampling x by factor greater than 10');
    end
    
    if (downsampleFactorY > 10)
        warning('downsampling y by factor greater than 10');
    end

    if (downsampleFactorX ~= 1)
        [n, d] = rat(commonFs/fsX);
        
        dsX = resample(x, n, d);
    else
        dsX = x;
    end
    if (downsampleFactorY ~= 1)
        [n, d] = rat(commonFs/fsY);
        
        dsY = resample(y, n, d);
    else
        dsY = y;
    end
    
%     dsY = bandpass(dsY, 70, 110, commonFs, 4);
%     dsX = bandpass(dsX, 70, 110, commonFs, 4);
    
%     dsX = downsample(x, downsampleFactorX);
%     dsY = downsample(y, downsampleFactorY);
    
    if (length(dsX) > length(dsY))
        longer = dsX; shorter = dsY;
        longerDownsampleFactor = downsampleFactorX;
    else
        longer = dsY; shorter = dsX; % or they're the same size
        longerDownsampleFactor = downsampleFactorY;        
    end

    if (flippedPolarityOk == true)
        result = abs(xcov(longer, shorter));
    else
        result = xcov(longer,shorter);
    end
    
    if (N == 1 && length(find(result == max(result))) == 1) % we can run fast in this case
        [peaks, locs] = findpeaks(result, 'minpeakheight', 0.999*max(result));
    else
        warning('searching for the N highest correlations, where N is greater than 1, unless you have a good reason for this, you might want to consider running with N=1');
        [peaks, locs] = findpeaks(result);
    end
    
    % remove values that are too high to be valid
    temp = (locs+length(shorter)<=length(result));
    locs = locs(temp);
    peaks = peaks(temp);

    % remove values that are too low to be valid
    temp = (locs >= length(longer)-length(shorter)+1);
    locs = locs(temp);
    peaks = peaks(temp);
    
    [rawCorrs, offsets] = nBiggest(peaks, locs, N, -(length(longer)-length(shorter))-1, 1, length(longer));
%     hold on; plot(ones(size(1:1000:2e7))*(2*length(longer)-length(shorter)-1), 1:1000:2e7, 'r');

    if (length(rawCorrs) == 0)
        warning('no peaks found');
    end
    
    if (doPlots == true)
        figure;
        plot(result);
        hold on;
        plot(offsets, rawCorrs, 'rx');
        axis tight;
        hold off;
    end
    
    % correct hits for the offset introduced by the xcorr function
    offsets = offsets - length(longer);
%    offsets = offsets-(length(result)-length(longer)-length(shorter)+1);
    
    % temp, get rid of the bad ones
    idxs = find(offsets < 1);
    offsets(idxs) = [];
    rawCorrs(idxs) = [];
    
    % now, normalize each of those correlation values by the
    % auto-correlation value for the same window
    
    corrs = zeros(size(rawCorrs));
    
    for c = 1:length(rawCorrs)
        window = longer(offsets(c):min(length(longer),offsets(c)+length(shorter)-1));
        normVal = dot(window, window);
        corrs(c) = rawCorrs(c) / normVal;
        
        if (doPlots == true)
            figure;
            title(sprintf('alignment possibility (%d), offset (%d), corrrMeasure (%f)', c, offsets(c), corrs(c)));
            subplot(211);
            plot(window);
            subplot(212);
            plot(shorter);
        end
    end
    
    if (isempty(corrs))
        corrs = 0;
        offsets = -1;
    else
        offsets = offsets * longerDownsampleFactor;    
    end
end

% this functinon returns the nBiggest peaks and corresponding locs
function [subPeaks, subLocs] = nBiggest(peaks, locs, n, modifier, min, max)
    [sortedPeaks, sortedLocs] = sort(peaks, 'descend');
    
    subPeaks = [];
    subLocs  = [];
    
    ctr = 0;
    for c = 1:length(sortedPeaks)
        comp = locs(sortedLocs(c)) + modifier;
        if (comp >= min && comp <= max)
            subPeaks(ctr+1) = sortedPeaks(c);
            subLocs(ctr+1) = locs(sortedLocs(c));
            ctr = ctr + 1;
        end
        
        if (ctr == n) 
            break;
        end
    end
end