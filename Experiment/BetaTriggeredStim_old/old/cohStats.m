function [C, hz, C_mu, C_sem] = cohStats(x, y, fs)
    n = size(x, 2);
    
    Cxx = mscohere(x(:,1), y(:,1), fs, fs/2, fs, fs);
    C = zeros(length(Cxx), n);
    
    for i = 1:n
        [C(:,n), hz] = mscohere(x(:,i), y(:,i), fs, fs/2, fs, fs);
    end
    
    C_mu = mean(C, 2);
    C_sem = sem(C, 2);
end