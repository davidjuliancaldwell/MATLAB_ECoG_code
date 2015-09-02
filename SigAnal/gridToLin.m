function Y = gridToLin(X, dims)
    if (numel(dims) ~= 2 || dims(2) ~= dims(1)+1)
        error('dims must be a two element, consecutive vector');
    end
    
    if (size(X, dims(1)) ~= 8 || ~ismember(size(X, dims(2)), 2:2:8))
        error('specified dimensions don''t seem like a sensible grid');
    end
    
    dimlist = 1:ndims(X);
    pdimlist = [setdiff(dimlist, dims) dims];
    
    pX = permute(X, pdimlist);
    
    szpX = size(pX);
    szpY = [szpX(1:(end-2)) szpX(end-1)*szpX(end)];
    
    pY = reshape(pX, szpY);
    
    ndimlist = [1:(dims(1)-1) ndims(pY) dims(1):(ndims(pY)-1)];
    Y = permute(pY, ndimlist);
end
    