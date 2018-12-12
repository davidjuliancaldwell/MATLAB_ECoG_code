function [P, fw, P_mu, P_sem] = mplv(x,y,fs,fw)
    
    
    [~, ~, X, foo] = time_frequency_wavelet(x, fw, fs, 1, 1, 'CPUtest');
    [~, ~, Y] = time_frequency_wavelet(y, fw, fs, 1, 1, 'CPUtest');
    
    pX = angle(X ./ abs(X));
    pY = angle(Y ./ abs(Y));
    
    aPhi = pX-pY;    
    phasors = exp(1i*aPhi);
    
    P = squeeze(abs(mean(phasors,1)));
    P_mu = mean(P, 2);
    P_sem = sem(P, 2);
end
