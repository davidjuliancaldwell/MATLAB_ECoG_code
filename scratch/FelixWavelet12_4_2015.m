x = rand(1000,10);

fw = [5 10 15 20];

fs = 1000; 

figure
hist(x(:,1))


[~,~,C,~] = time_frequency_wavelet(x,fw,fs,0,1,'CPUtest');

%% plotting abs
figure
subplot(4,1,1)
plot(abs(C(:,1,1)));

subplot(4,1,2)
plot(abs(C(:,2,1)));

subplot(4,1,3)
plot(abs(C(:,3,1)));

subplot(4,1,4)
plot(abs(C(:,4,1)));

%% plotting real
figure
subplot(4,1,1)
plot(real(C(:,1,1)));

subplot(4,1,2)
plot(real(C(:,2,1)));

subplot(4,1,3)
plot(real(C(:,3,1)));

subplot(4,1,4)
plot(real(C(:,4,1)));


%% z score

x = abs(C(:,1,1));
Z = (x-mean(x))/std(x);
figure
plot(Z)

%% 12-7-2015 - try it with kaitlyn data - load in ecb43e PAC baseline data

load('D:\BigDataFiles\ecb43e_PAC_baseline.mat')

% larry said channel 63 
a = data(:,63);
t_a = (0:length(a)-1)/fs;
figure
plot(t_a,a)

%% try it with ecb43e PA prebaseline data 

load('D:\BigDataFiles\ecb43e_PAC_prestim.mat')

% pick channel of interest 
a = data(:,63);
t_a = (0:length(a)-1)/fs;
figure
plot(t_a,a)


%% 
fw = [12:25];
[~,~,C,~] = time_frequency_wavelet(a,fw,fs,0,1,'CPUtest');
Cabs = abs(C);

nC = normalize_plv(Cabs', Cabs');

t = 0:length(nC)/fs;

figure
imagesc(t, fw, Cabs'); axis xy
xlabel('Time in seconds')
ylabel('Frequency')
colorbar
title('Wavelet analysis for beta') 
xlim([100 110])
