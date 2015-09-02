function fwhm = calcFWHM(winWidthSec)
    fs = 1000;
    
    mwin = gausswin(winWidthSec * fs);
    
    start = find(mwin>.5, 1, 'first')-1;
    finish = find(mwin>.5, 1, 'last')+1;
    
    fwhm = (finish-start) / fs;        
end