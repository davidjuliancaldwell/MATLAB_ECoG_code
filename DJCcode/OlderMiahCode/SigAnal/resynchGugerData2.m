function [rsig, rsta] = resynchGugerData2(sig, sta, chansPerAmp, chansToIgnore)
    if (~exist('chansPerAmp', 'var') || isempty(chansPerAmp))
        chansPerAmp = 4;
    end
    if (~exist('chansToIgnore', 'var'))
        chansToIgnore = [];
    end
    
    for i = 1:size(sig,2);
        if ismember(i,chansToIgnore);
            sig(:,i) = zeros(size(sig,1),1);
        end
    end
    
    nChans = size(sig, 2);
    
    ampEndChans = cumsum(GugerizeMontage(nChans));
    ampStartChans = [1 ampEndChans(1:(end-1))+1];
    
    nAmps = length(ampEndChans);
    
%     keeperChannels = [];
%     keeperAmps = [];
%     
%     for c = 1:nAmps
%         goodChansForAmp = ampStartChans(c):ampEndChans(c);
%         goodChansForAmp(ismember(goodChansForAmp, chansToIgnore)) = [];
%         
%         if (isempty(goodChansForAmp))
%             warning('no good channels from amplifier %d, not including', c);
%             
%         elseif (length(goodChansForAmp) < chansPerAmp)
%             warning('not enough channels in amplifier %d, using only %d', c, length(goodChansForAmp));
%             keeperChannels = cat(2, keeperChannels, goodChansForAmp);
%             keeperAmps = cat(2, keeperAmps, repmat(c, 1, length(goodChansForAmp)));
%         else
%             keeperChannels = cat(2, keeperChannels, goodChansForAmp(randperm(length(goodChansForAmp), chansPerAmp)));
%             keeperAmps = cat(2, keeperAmps, repmat(c, 1, chansPerAmp));
%         end        
%     end
    
%     asig = bandpass(double(sig(:,1:size(nAmps, 2))), 70, 100, 1200, 4);
    
%     while size(ampEndChans,2) > nAmps || size(ampStartChans,2) > nAmps;
%         ampEndChans(:,end) = [];
%         ampStartChans(:,end) = [];
%     end
     
    fsig = bandpass(double(sig(:,1:nChans)), 70, 100, 1200, 4);

    lags = calcLag(fsig, chansToIgnore);
    
%     [~, order] = sort(mean(lags,2),'descend');
    
    littlelag = zeros(nAmps, nAmps);
    
    % find the lag for each amp
    for i = 1:nAmps;
        for j = 1:nAmps;
            ampBlock = lags(ampStartChans(i):ampEndChans(i), ampStartChans(j):ampEndChans(j));
            if nanmean(ampBlock(:)) ~= nanmode(ampBlock(:));
                warning('check for bad channels that were not screened out already');
            end
            littlelag(i,j) = nanmode(ampBlock(:));
        end
    end
    
    blockSize = ones(chansPerAmp, chansPerAmp);
    %resize littlelags to dimensions of lags
    for i = 1:nAmps;
        for j = 1:nAmps;
            movement(ampStartChans(i):ampEndChans(i), ampStartChans(j):ampEndChans(j)) = blockSize * littlelag(i,j);
        end
    end
    
    maxlag = max(max(abs(movement)));

    newLength = 1:(size(sig,1)-maxlag)';
        
    firstAmpIdxs = [ampStartChans(1):1:ampEndChans(1)];
%     ampShifts = [];
%     staShifts = 1:(size(asig,1)-max(abs(movement)));
    rsig = sig(newLength, ampStartChans(1):ampEndChans(1));

    
    for ampNum = 2:nAmps
        ampIdxs = [ampStartChans(ampNum):1:ampEndChans(ampNum)];        
        compLags = movement(firstAmpIdxs, ampIdxs);
        
        if (sum(compLags ~= median(compLags(:))) > 0)
            warning('not all lags from amp 1 to amp %d were equivalent', ampNum);
        end

        cIdx = ampStartChans(ampNum):ampEndChans(ampNum);
        
        ts = 1:(size(sig,1)- maxlag);
        
        if (~isempty(movement(:)))
            if isnan(movement(ampStartChans(ampNum)));
                lag = 0;
            else
                lag = movement(ampStartChans(ampNum));
            end
            tIdx = ts - lag;
%             if tIdx(1) == 0;
%                 tIdx(1) = [];
%             end
            rsig = cat(2, rsig, sig(tIdx, cIdx ));
        else
            rsig = cat(2, rsig, sig(newLength, cIdx));
        end
    end
    
    rsta = struct;
    for field = fieldnames(sta)'
        rsta.(field{:}) = sta.(field{:})(newLength);
    end
    
end