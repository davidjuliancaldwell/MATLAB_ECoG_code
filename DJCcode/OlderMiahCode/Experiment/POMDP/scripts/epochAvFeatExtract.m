function feats = epochAvFeatExtract(data, labels, istr)
    % data are OBS x CHANS x T
    OBS = size(data, 1);
    
    feats = mean(data, 3); % OBS x CHANS
    
    mu = mean(feats(istr, :), 1); % 1 x CHANS
    sig = std(feats(istr, :), 1); % 1 x CHANS
    
    feats = (feats - repmat(mu, [OBS 1])) ./ repmat(sig, [OBS 1]);
end
    