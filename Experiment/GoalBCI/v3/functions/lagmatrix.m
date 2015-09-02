function Y = lagmatrix(X, lags)
    % X is an obs (time) by channels matrix
    % lags is a 1xN or Nx1 vector
    
    % returns y as a duplicated version of X shifted in time by lags and nanpadded
    % as necessary
   
    nT = size(X, 1);
    nC = size(X, 2);
    
    Y = zeros(nT, nC * length(lags));
    
    for idx = 1:length(lags)
        lag = lags(idx);
        
        startCol = (idx-1)*nC + 1;
        endCol   = idx*nC;
       
        shifted = circshift(X, lag);
        
        if (lag > 0)
            if (lag <= size(shifted, 1))
                shifted(1:lag, :) = NaN;
            else
                shifted(:,:) = NaN;
            end
            
        elseif (lag < 0)
            if (-lag <= size(shifted, 1))
                shifted((end+lag+1):end, :) = NaN;
            else
                shifted(:,:) = NaN;
            end
        end
        
        Y(:, startCol:endCol) = shifted;        
    end
end