function plv = plv_revisedParallel( analyzeBand )
% makes a diagonal matrix of PLV values

numChannels = size(analyzeBand, 2);

phaseData = zeros(size(analyzeBand));

% fprintf('evaluating PLVs \n');

parfor iChan = 1:numChannels;
    phaseData(:, iChan) = angle(hilbert(analyzeBand(:, iChan)));
end

plv = zeros(numChannels, numChannels);


for iChan = 1:numChannels;
    chanPhase = phaseData(:, iChan); %grab the data from one channel
    for compChan = iChan:numChannels; %note that it only calculates the upper portion of the diagonal matrix (other side is mirrored)
        compChanPhase = phaseData(:, compChan); %grab the data from another channel to compare to the first one (only higher # channels included)
        relPhase(:,1) = chanPhase(:,1) - compChanPhase(:,1); %find difference in phase between them
        plv(iChan, compChan) = abs(sum(exp(1i*relPhase))/length(relPhase)); 
        %absolute value of the sum of e to I * the relative phase, divided by length of that vector to normalize
    end
end

end

