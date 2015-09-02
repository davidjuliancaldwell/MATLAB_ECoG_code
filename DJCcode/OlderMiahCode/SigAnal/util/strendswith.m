function result = strendswith(test, pattern)
    locs = strfind(test, pattern);
    
    if (isempty(locs))
        result = false;
        return;
    end
    
    result = (locs(end) + length(pattern) - 1 == length(test));
end