function lags = calcLag(data, badchans)
    pairs = nchoosek(1:size(data, 2), 2);
    
    
    h = waitbar(0, 'calculating lags for all channels');
    
    lags = zeros(size(data, 2));
    
    for c = 1:size(pairs, 1)
        if (mod(c, 10) == 0)
            waitbar(c/size(pairs, 1), h);
        end
        
        if any(ismember(pairs(c,:), badchans))
            lags(pairs(c,1), pairs(c,2)) = NaN;
        else
            lags(pairs(c,1), pairs(c,2)) = calcLagSub(data(:, pairs(c,1)), data(:, pairs(c,2)), 40);
        end
    end
    
    lags = lags - lags';
    
    close(h);
end

function lag = calcLagSub(x,y,maxLag)
    [vals, lags] = xcorr(x,y,maxLag);
    
    [~, lagLoc] = max(vals);
    lag = lags(lagLoc);
end