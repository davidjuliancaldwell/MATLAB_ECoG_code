%% From Power Spectral Density Estimates Using FFT
% Periodogram of signal using FFT
% x is the signal, Fs is the sampling frequency 
% this is from http://www.mathworks.com/help/signal/ug/psd-estimate-using-fft.html

function [freq,psdx] = fftDJC(x,Fs)
N = length(x);
Fs = double(Fs);
xdft = fft(x);
xdft = xdft(1:N/2+1);
psdx = (1/(Fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:Fs/length(x):Fs/2;

plot(freq,10*log10(psdx))
grid on
title('Periodogram Using FFT')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')
end 