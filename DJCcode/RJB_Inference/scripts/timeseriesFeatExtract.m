function feats = timeseriesFeatExtract(data, labels, istr)
    % data are OBS x CHANS x T
    OBS = size(data, 1);
    
    for chan = 1:size(data, 2)
        data(:, chan, :) = GaussianSmooth(squeeze(data(:, chan, :)), 20)';
    end
    
    [C, K] = getEpFilters(data(istr, :, :), labels(istr));
    feats = getEpProjections(data, C, K);
        
    mu = mean(feats(istr, :), 1); % 1 x CHANS
    sig = std(feats(istr, :), 1); % 1 x CHANS
    
    feats = (feats - repmat(mu, [OBS 1])) ./ repmat(sig, [OBS 1]);
end
    