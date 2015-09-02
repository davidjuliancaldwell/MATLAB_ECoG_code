function dFeatures = discretizeFeatures(features)
    % on a channel by channel basis, normalize and discretize in to N-bit
    % space
    
    minVal = 0;
    maxVal = 2^8 - 1;

    dFeatures = uint8(zeros(size(features)));
    
    for chan = 1:size(features, 1)
        raw = map(features(chan,:), min(features(chan,:)), max(features(chan,:)),minVal,maxVal);
        dFeatures(chan, :) = uint8(round(raw));
    end
end