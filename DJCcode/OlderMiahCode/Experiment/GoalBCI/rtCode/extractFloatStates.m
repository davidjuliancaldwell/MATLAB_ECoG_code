function statesAsFloat = extractFloatStates(sta)
    epos = extractStatesMatching(sta, '_Epos');
    mpos = extractStatesMatching(sta, '_Mpos');
    e = extractStatesMatching(sta, '_E$');
    m = extractStatesMatching(sta, '_M$');
    
    exponent = (epos*2 - 1) .* e;
    mantissa = (mpos*2 - 1) .* m;
    
    statesAsFloat = mantissa .* 10.^exponent;
end