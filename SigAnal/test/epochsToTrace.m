function trace = epochsToTrace(starts, ends, length)
    temp = zeros([1 length]);
    
    temp(starts) = 1;
    temp(ends) = -1;
    
    trace = cumsum(temp);
end