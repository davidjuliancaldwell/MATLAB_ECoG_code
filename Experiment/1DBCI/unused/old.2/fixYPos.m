function new = fixYPos(old)
    % assumes old is a 16 bit unsigned integer,
    % performs appropriate wrapping to change to a signed double
    
    flippedFlag = old > 2^15;
    
    new = double(old);
    
    new(flippedFlag) = new(flippedFlag) - 2^16;

end