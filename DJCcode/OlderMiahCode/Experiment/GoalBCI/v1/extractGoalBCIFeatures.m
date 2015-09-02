function [features, targets, results] = extractGoalBCIFeatures(sig, sta, par, frequencies, Montage, winSize)
    % preprocess signal
    fsamp = par.SamplingRate.NumericValue;    
    
    sig = double(sig);
    sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, sig);
    sig = notch(sig, [120 180], fsamp, 4);
    
    % determine the epochs of interest
    [rs, re, ts, te, hs, he, fs, fe] = identifyFullEpochs(sta, par);

    % save the target and result vectors
    targets = double(sta.TargetCode(fs));
    results = double(sta.ResultCode(fe+1));
    
    % features is going to be TxNxWxO
    % where T is the number of X millisecond chunks for the data
    %       N is the number of channels
    %       W is the number of frequency bins
    %       O is the number of observations
    nfeats = (mode(te-ts+1)/(winSize*fsamp)) + (mode(he-hs+1)/(winSize*fsamp));
    
    features = zeros(nfeats, length(te), size(sig, 2), size(frequencies, 1));
    
    for fidx = 1:size(frequencies, 1)
        blp = zscore(log(hilbAmp(sig, frequencies(fidx, :), fsamp).^2));                
        windowLength = mode(he-ts+1);
        featureLength = winSize*fsamp;

        samples = bsxfun(@plus,ts,(1:windowLength)');
        windows = reshape(blp(samples,:), [windowLength length(ts) size(blp, 2)]);

        featWindows = reshape(windows, featureLength, size(windows,1)/featureLength, size(windows, 2), size(windows, 3));    
        
%         mFeats = squeeze(mean(featWindows, 1));        
%         features(:, :, :, fidx) = mFeats;

        features(:,:,:,fidx) = squeeze(mean(featWindows, 1));
    end            
end