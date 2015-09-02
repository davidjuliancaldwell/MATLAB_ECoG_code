function y = replayRandomizeSignal(x)
    X = fft(x);
    phaseX = X./abs(X);
    randphaseX = phaseX(randperm(length(phaseX)),:);
    y = real(ifft(abs(X).*randphaseX));
end