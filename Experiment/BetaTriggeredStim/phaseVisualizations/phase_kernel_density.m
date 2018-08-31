function [peakDeg,peakStd] = phase_kernel_density(signal,plotIt)
% expects time x channels

numChans = size(signal,2);
peakDeg = nan(1,numChans);
peakStd = nan(1,numChans);
for i = 1:numChans
    
    if sum(~isnan(signal(:,i)))
        [peakDensity,xi] = ksdensity(rad2deg(signal(:,i)));
        [maxDensity,peakIndex,peakStd(i)] = findpeaks(peakDensity,'sortstr','descend','npeaks',1);
        peakDeg(i) = (xi(peakIndex));
        %peakStd(i) = nanstd(signal(:,i))/sqrt(sum(~isnan(signal(:,i))));
        %This shows you what the smoothed density looks like:
        
        if plotIt
            figure
            ksdensity(rad2deg(signal(:,i)))
            vline(peakDeg(i))
            title(['Channel ' num2str(i)])
        end
    end
    
end