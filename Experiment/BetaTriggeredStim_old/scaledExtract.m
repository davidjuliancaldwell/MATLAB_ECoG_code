function [Y, finalCoeff, best] = scaledExtract(X, mu)
    % X is time by obs
    % mu is time x 1

    start = -10;
    stop = 10;
    N = 21;
    
    best = Inf;
    delta = 1e-6;
    maxIter = 5;
    iter = 0;
    
    if (corr(X,mu) < 0)
        mu = -mu;
    end
    
    while (best > delta && iter < maxIter)
        iter = iter+1;
        
        exps = linspace(start, stop, N);
        coeffs = logspace(start, stop, N);
                
        residuals = zeros(size(coeffs));
        
        for idx = 1:length(coeffs)
            coeff = coeffs(idx);

            Yhat = X-repmat(coeff*mu, 1, size(X, 2));
            residuals(idx) = sqrt(mean(Yhat(:).^2));
        end        
    
        [best, besti] = min(residuals);
        fprintf('iteration %d: attempting 2^%f to 2^%f, found a minimum residual of %f\n', iter, exps(1), exps(end), best);
        
        start = exps(max(besti - 1, 1));
        stop  = exps(min(besti + 1, N)); 
    end
        
    finalCoeff = coeffs(besti);
    
    Y = X-repmat(finalCoeff*mu, 1, size(X, 2));
    
end