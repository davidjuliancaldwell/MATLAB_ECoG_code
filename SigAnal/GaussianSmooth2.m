function ret = GaussianSmooth2(X, width, sigmas)
    gfilt = customgauss(width, sigmas(1), sigmas(2), 0, 0, 1, [0 0]);
    gfilt = gfilt / sum(sum(gfilt));
    [r,c] = size(gfilt);
    rs = ceil(r/2);
    re = floor(r/2);
    cs = ceil(c/2);
    ce = floor(c/2);

    ret = conv2(X,gfilt,'same');    
    ret = ret(rs:(end-re),cs:(end-ce));
end