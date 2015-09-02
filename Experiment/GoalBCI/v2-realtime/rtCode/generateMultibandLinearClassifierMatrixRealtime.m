function values = generateMultibandLinearClassifierMatrixRealtime(nChans, bins, ctlbin, xControlChannel, yControlChannel, zControlChannel)
    %% needed variables

    values = zeros(sum(bins==ctlbin)*3+(nChans)*sum(bins>0), 4);
    
    % add lines for the control channels
    ctlbins = find(bins==ctlbin);
    nCtlbins = length(ctlbins);
    
    for binidx = 1:nCtlbins
        values(binidx, :) = [xControlChannel, ctlbins(binidx), 1, 1];
        values(nCtlbins+binidx, :) = [yControlChannel, ctlbins(binidx), 2, 1];
        values(2*nCtlbins+binidx, :) = [zControlChannel, ctlbins(binidx), 3, 1];
    end

    idx = nCtlbins*3 + 1;
    
    bands = unique(bins);
    bands(bands == 0) = [];
    
    for bandIdx = 1:length(bands)
        band = bands(bandIdx);
        binsForBand = find(bins==band);
        nBinsForBand = length(binsForBand);
        
        for chan = 1:nChans
            for binInBand = binsForBand

                values(idx, :) = [chan, binInBand, chan+(nChans*(bandIdx-1))+3, 1/nBinsForBand];
                idx = idx+1;
            end
        end
    end

%     fclose(handle);
% 
%     %% display the result
%     fprintf('Success: %d lines written to %s\n', lineCount, outputFilepath);
end
    