function [mu, SEM, classes, N, sigma] = barStats(data, class)
    classes = unique(class);
    
    mu = zeros(size(classes));
    sigma = zeros(size(classes));
    N = zeros(size(classes));
    SEM = zeros(size(classes));
    
    for cidx = 1:length(classes)
        idxs = classes(cidx) == class;
        mu(cidx) = mean(data(idxs));
        sigma(cidx) = std(data(idxs));
        N (cidx) = sum(idxs);
        
        if ( N(cidx) > 0)
            SEM(cidx) = sigma(cidx) / sqrt(N(cidx));
        else
            SEM(cidx) = 0;
        end
    end
end