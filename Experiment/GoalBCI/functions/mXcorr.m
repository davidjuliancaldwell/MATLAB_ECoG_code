function [c, lags] = mXcorr(x, Y, maxlag)
    % simultaneously cross-correlates x (a vector) with the rows of Y (a
    % matrix)

    % can assume same length
    [M,N] = size(x);
    P = size(Y, 2);
    
    % Transform both vectors
    fX = fft(x,2^nextpow2(2*M-1));
    fY = fft(Y,2^nextpow2(2*M-1));

    % Compute cross-correlation
    c = ifft(repmat(fX, 1, P).*conj(fY));
    
    % force real because we know the inputs are real    
    c = real(c);
    
    lags = -maxlag:maxlag;


    % Keep only the lags we want and move negative lags before positive lags
    if maxlag >= M,
        c = [zeros(maxlag-M+1,P);c(end-M+2:end,:);c(1:M,:);zeros(maxlag-M+1,P)];
%         c = [zeros(maxlag-M+1,N^2);c(end-M+2:end,:);c(1:M,:);zeros(maxlag-M+1,N^2)];
    else
        c = [c(end-maxlag+1:end,:);c(1:maxlag+1,:)];
    end    
    
    % perform the appropriate scaling
    cxx0 = sum(abs(x).^2);
    cyy0 = sum(abs(Y).^2);
    scale = sqrt(cxx0*cyy0);
    c = bsxfun(@rdivide, c, scale);
    
    c(isnan(c)) = 0;
end