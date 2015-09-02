function D = dtw_multi_multichan(X, w)
    % X is obs x chans x time
    % w is the distance parameter
    % D will be returned as obs x obs
    % D_vec is optional and will return the vector form of the distance
    % matrix
    
%     if (ndims(X) ~= 3)
%         error 'dimensionality of X is incorrect'
%     end
%     
    D = zeros(size(X, 1));
    
    for obsI = 1:size(X, 1)
        for obsJ = (obsI+1):size(X, 1)
            D(obsI, obsJ) = dtw_c(squeeze(X(obsI, :, :))', squeeze(X(obsJ, :, :))', w);            
        end
    end
    
    D = D+D';
    
    if (nargout > 1)
        D_vec = squareform(D, 'tovector');
    end
end