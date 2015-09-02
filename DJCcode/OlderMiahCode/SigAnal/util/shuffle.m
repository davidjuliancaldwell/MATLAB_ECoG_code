function Y = shuffle(X, dim)
    if (~exist('dim','var'))
        X = shiftdim(X); % work along first non-singleton dimension
        dim = 1;
    end
    
    ndim = ndims(X);
    
    X = shiftdim(X, dim-1);
    
    idxs = randperm(size(X, 1));
    Y = zeros(size(X));
    
    for c = 1:length(idxs)
        Y(c,:,:) = X(idxs(c),:,:);
    end
    
    Y = shiftdim(Y, ndim-(dim-1));
end