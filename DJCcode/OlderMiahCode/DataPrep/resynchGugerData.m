function [rsig, rsta] = resynchGugerData(sig, sta, chansPerAmp, chansToIgnore)
    if (~exist('chansPerAmp', 'var') || isempty(chansPerAmp))
        chansPerAmp = 4;
    end
    if (~exist('chansToIgnore', 'var'))
        chansToIgnore = [];
    end
    
    nChans = size(sig, 2);
    
    ampEndChans = cumsum(GugerizeMontage(nChans));
    ampStartChans = [1 ampEndChans(1:(end-1))+1];
    
    nAmps = length(ampEndChans);
    
    keeperChannels = [];
    keeperAmps = [];
    
    for c = 1:nAmps
        goodChansForAmp = ampStartChans(c):ampEndChans(c);
        goodChansForAmp(ismember(goodChansForAmp, chansToIgnore)) = [];
        
        if (isempty(goodChansForAmp))
            warning('no good channels from amplifier %d, not including', c);
            
        elseif (length(goodChansForAmp) < chansPerAmp)
            warning('not enough channels in amplifier %d, using only %d', c, length(goodChansForAmp));
            keeperChannels = cat(2, keeperChannels, goodChansForAmp);
            keeperAmps = cat(2, keeperAmps, repmat(c, 1, length(goodChansForAmp)));
        else
            keeperChannels = cat(2, keeperChannels, goodChansForAmp(randperm(length(goodChansForAmp), chansPerAmp)));
            keeperAmps = cat(2, keeperAmps, repmat(c, 1, chansPerAmp));
        end        
    end
    
    asig = bandpass(double(sig(:,:)), 70, 100, 1200, 4);
    
    fsig = bandpass(double(sig(:,keeperChannels)), 70, 100, 1200, 4);

    lags = calcLag(fsig);
    
    %assume neg lags in northeast corner of lag grid
    maxlag = max(max(abs(lags)));
    
    firstAmpIdxs = keeperAmps==1;
%     ampShifts = [];
    staShifts = 1:(size(asig,1)-maxlag);
    rsig = sig(staShifts, ampStartChans(1):ampEndChans(1));

    
    for ampNum = 2:nAmps
        ampIdxs = keeperAmps==ampNum;        
        compLags = lags(firstAmpIdxs, ampIdxs);
        
        if (sum(compLags ~= median(compLags(:))) > 0)
            warning('not all lags from amp 1 to amp %d were equivalent', ampNum);
        end

        cIdx = ampStartChans(ampNum):ampEndChans(ampNum);
        
        if (~isempty(compLags(:)))
            lag = median(compLags(:));
            tIdx = (1:(size(sig,1)-maxlag))-lag;
            rsig = cat(2, rsig, sig(tIdx, cIdx ));
        else
            rsig = cat(2, rsig, sig(staShifts, cIdx));
        end
    end
    
    rsta = struct;
    for field = fieldnames(sta)'
        rsta.(field{:}) = sta.(field{:})(staShifts);
    end
end