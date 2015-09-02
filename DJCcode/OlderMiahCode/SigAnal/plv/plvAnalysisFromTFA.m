function plv = plvAnalysisFromTFA(X, Y)
    %X&Y are TFA decomposed matrices for individual channels, such that
    % either one is of dimension TxWxO
    %   T is the number of samples
    %   W is the number of frequencies used in wavelet decomposition
    %   O is the number of observations
    
    % plv is a matrix of the same dimensionality that corresponds to the
    % time-variant phase locking between X and Y
    
    Xp = angle(X);
    Yp = angle(Y);
    
    theta = Xp-Yp;
    plv = exp(1i*theta);    
end