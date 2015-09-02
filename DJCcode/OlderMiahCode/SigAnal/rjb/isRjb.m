function result = isRjb(sta)
    % for now, simple test
    [starts, ends] = getEpochs(double(sta.Feedback), 1, 0);
    L = ends-starts;
    
    result = length(unique(L)) <= 2;    
end