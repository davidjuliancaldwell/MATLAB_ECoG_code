function [X, hz, X_mu, X_sem] = spectralStats(x, fs)
    n = size(x, 2);
    
    [X, hz] = pwelch(x(:,1), fs, fs/2, fs, fs);
    X = zeros(size(X, 1), size(x, 2), size(x, 3));

    for i = 1:n
        X(:,i) = log(pwelch(x(:,i), fs, fs/2, fs, fs));
    end
    
    X_sem = sem(X, 2);
    X_mu = mean(X, 2);
end