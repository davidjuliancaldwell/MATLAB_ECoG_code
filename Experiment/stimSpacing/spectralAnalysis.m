%% 7-1-2016 - Spectral Analysis Script after talking to Bing and Nathan - DJC

% make sure data is loaded in 
function [f,P1] = spectralAnalysis(fs_data,t,dataEpoched)
fs = fs_data;
T = 1/fs;
L = length(dataEpoched);

Y = fft(dataEpoched);
P2 = abs(Y/L);
P1 = P2(1:floor(L/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:floor(L/2))/L;

subplot(2,1,1)
hold on
plot(f,P1,'linewidth',[2])
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')
xlim([0 500])
set(gca,'fontsize',14)

subplot(2,1,2)
hold on
plot(t,dataEpoched,'linewidth',[2])
title('time series')
xlabel('time (ms)')
ylabel('ampltitude (V)')
set(gca,'fontsize',14)


end