function Y = linToGrid(X, dim)
    % X is a matrix with one dimension corresponding to electrode number,
    % this scipt attempts to reshape this matrix in to it's 'gridlike'
    % shape.
    
    N = size(X, dim);
    
    if (N == 64)
        xdim = 8;
        ydim = 8;
    elseif (N == 48)
        xdim = 8;
        ydim = 6;
    elseif (N == 32)
        xdim = 8;
        ydim = 4;
    elseif (N == 16)
        xdim = 8;
        ydim = 2;
    else
        error ('grid dimension does not fit my model of what a grid should be shaped like');
    end
    
    dimlist = 1:ndims(X);
    rdimlist = [setdiff(dimlist, dim) dim];
    
    pX = permute(X, rdimlist);
    szpX = size(pX);
    szpX(end) = xdim;
    szpX(end+1) = ydim;
    
    pY = reshape(pX, szpX);
    
    ndimlist = [1:(dim-1) length(szpX)-1 length(szpX) dim:(ndims(pY)-2)];
    
    Y = permute(pY, ndimlist);    
end