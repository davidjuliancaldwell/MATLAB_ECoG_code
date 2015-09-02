function zscored = zscoreAgainstInterest(signals, codes, codeOfInterest)
% function zscored = zscoreAgainstInterest(signals, codes, codeOfInterest)
%
% calculates the zscore of all samples in signals on a channel by channel
% bases.  The zscore is calculated relative to the mean and standard
% deviations taken only from samples that occur when codes ==
% codeOfInterest.
%

%     [starts, ends] = getEpochs(codes, codeOfInterest);
%     
%     idxs = find(ends-starts ~= mode(ends-starts));
%     starts(idxs) = [];
%     ends(idxs) = [];
%     
%     interestEpochs = getEpochSignal(signals, starts, ends);

    baseSamples = signals(codes == codeOfInterest, :);
    
%     if (size(interestEpochs, 2) ~= 1)
        mu = mean(baseSamples);
        sig = std(baseSamples);
        
%         interestMeans = squeeze(mean(interestEpochs, 1));
%         interestDev   = squeeze(std(interestEpochs, 0, 1));
% 
%         mu = squeeze(mean(interestMeans, 2));
%         sig = squeeze(mean(interestDev, 2));

        muMat = repmat(mu, [size(signals,1) 1]);
        sigMat = repmat(sig, [size(signals,1) 1]);

        zscored = (signals - muMat) ./ sigMat;
%     else
%         interestMeans = squeeze(mean(interestEpochs, 1));
%         interestDev   = squeeze(std(interestEpochs, 0, 1));
%         
%         mu = mean(interestMeans);
%         sig = mean(interestDev);
%         
%         muMat = repmat(mu, [1 size(signals,1)]);
%         sigMat = repmat(sig, [1 size(signals,1)]);
%         
%         zscored = (signals - muMat') ./ sigMat';
%     end
end