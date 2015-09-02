% assumes that the chunks from x and y have the same offset/length

function crosscov = wideXCov(x, y, start, endd, preLag, postLag)
    assert(endd - start > 0, 'must have non-zero and non-negative chunk of data to test');
    assert(start - preLag > 0, 'preLag extends beyond beginning of data');
    assert(endd + postLag <= length(x), 'postLag extends beyond end of x');
    assert(endd + postLag <= length(y), 'postLag extends beyond end of y ');
    
    subx = x(start:endd);
    suby = y(start-preLag:endd+postLag);
    
    temp = xcov(subx, suby);
%     ind = 1:length(temp);
%     figure; plot(ind, temp);
%     hold on;
    ind = length(subx):length(subx)+preLag+postLag;
%     plot(ind, temp(ind), 'r');
    
    crosscov = temp(ind);
end

