function values = generateLinearClassifierMatrixPosthoc(nChans, nBins)
    values = zeros(nChans*nBins, 4);
    
    for chan = 1:nChans
        for bin = 1:nBins
            values(nBins*(chan-1) + bin, :) = [chan, bin, chan, 1];
        end
    end
end
    