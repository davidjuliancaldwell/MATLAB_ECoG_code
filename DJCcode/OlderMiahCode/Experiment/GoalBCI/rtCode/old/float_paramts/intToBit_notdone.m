function bitRep = intToBit(intRep)
    nBits = nextpow2(intRep);
    
    bitRep = false(nBits, 1);
    
    idx = 0;
    while (intRep > 0)
        
        intRep = intRep / 2;
        idx = idx + 1;
    end
end