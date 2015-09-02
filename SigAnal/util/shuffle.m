function Y = shuffle(X, dim)
    if (~exist('dim','var'))
        dim = 1;
    end

    % special case
    wasrow = false;
    if (isrow(X))
        wasrow = true;
        X = X';
    end
    
    ndim = ndims(X);
    
    if (ndim > 3)
        error('doesn''t currently work on matrices of ndims < 3');
    end
    
    order = [dim setdiff(1:ndim, dim)];
    
    X_prime = permute(X, order);    
    idxs = randperm(size(X_prime, 1));

    Y_prime = X_prime(idxs, :, :);
    
    [~, rorder] = sort(order);
    Y = permute(Y_prime, rorder);
    
    if (wasrow)
        Y = Y';
    end
end