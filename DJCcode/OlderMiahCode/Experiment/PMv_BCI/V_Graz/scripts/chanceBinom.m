function [chance, hv, lv] = chanceBinom(p, trials, N)

    if (nargin < 3)
        N = 1000;
    end
    
    hr = zeros(N,1);

    for c = 1:N
        hr(c) = binornd(trials,p)/trials;
    end

    shr = sort(hr);
    lidx = ceil((0.05/2)*N);
    hidx = floor((1-(0.05/2))*N);
    
    chance = mean(shr);
    hv = shr(hidx);
    lv = shr(lidx);
end