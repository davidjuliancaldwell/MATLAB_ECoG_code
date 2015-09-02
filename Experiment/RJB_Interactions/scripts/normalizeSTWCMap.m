function nMap = normalizeSTWCMap(map, includeInBaseline)
    map(isnan(map)) = 0;
    
    base = map(:, includeInBaseline);
    base = base(:);
    
    mu = mean(base);
    sig = std(base);
    
    nMap = (map-mu)/sig;
end