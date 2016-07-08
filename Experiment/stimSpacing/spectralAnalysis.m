%% 7-1-2016 - Spectral Analysis Script after talking to Bing and Nathan - DJC

% make sure data is loaded in 
function [f,P1] = spectralAnalysis(fs_data,t,dataEpoched)

[f,P1] = spectralAnalysisComp(fs_data,dataEpoched);

subplot(3,1,1)
plot((f),(P1),'linewidth',[2])
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')
xlim([0 100])
ylim([0 2e-5])
set(gca,'fontsize',14)
hold on

subplot(3,1,2)
loglog((f),(P1),'linewidth',[2])
title('Single-Sided Amplitude Spectrum of X(t) -loglog')
xlabel('f (Hz)')
ylabel('|P1(f)|')
% xlim([0 500])
ylim([10e-10 10e-4])

set(gca,'fontsize',14)
hold on


subplot(3,1,3)
plot(t,dataEpoched,'linewidth',[2])
title('time series')
xlabel('time (ms)')
ylabel('ampltitude (V)')
set(gca,'fontsize',14)
xlim([-500 500])
ylim ([-1e-4 1e-4])
hold on

% set legend
legend({'pre','low','mid','high'})

end