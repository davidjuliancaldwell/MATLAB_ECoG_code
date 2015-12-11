%% 12-7-2015 - Trying to do something similar to Larry's wavelets

%% load in ecb43e PAC baseline data

load('D:\BigDataFiles\ecb43e_PAC_baseline.mat')

% larry said channel 63 
a = data(:,63);
t_a = (0:length(a)-1)/fs;
figure
plot(t_a,a)

%% load in ecb43e PAC prestim data

load('D:\BigDataFiles\ecb43e_PAC_prestim.mat')

% pick channel of interest 
a = data(:,63);
t_a = (0:length(a)-1)/fs;
figure
plot(t_a,a)

%% start by making t vector, and then a 12 hz packet in 1 second block 
t = linspace(0, 1, 600)';
sin12 = @(x) sin(2*pi*12*t);
b = sin12(t)';
plot(t,b)

%% different packet sizes

pack1 = [b(1:50) zeros(550,1)'];
pack2 = [b(1:100) zeros(500,1)'];
pack3 = [b(1:150) zeros(450,1)'];
pack4 = [b(1:200) zeros(400,1)'];
pack5 = [b(1:250) zeros(350,1)'];
pack6 = [b(1:300) zeros(300,1)'];

figure
plot(t,pack1,t,pack2,t,pack3,t,pack4,t,pack5,t,pack6)
legend('1','2','3','4','5','6')

%%

pack1x = xcorr(a,pack1);
pack1x = pack1x(length(a):end);

pack2x = xcorr(a,pack2);
pack2x = pack2x(length(a):end);

pack3x = xcorr(a,pack3);
pack3x = pack3x(length(a):end);

pack4x = xcorr(a,pack4);
pack4x = pack4x(length(a):end);

pack5x = xcorr(a,pack5);
pack5x = pack5x(length(a):end);

pack6x = xcorr(a,pack6);
pack6x = pack6x(length(a):end);

figure

plot(t_a,pack1x)
hold on
plot(t_a,pack2x)
plot(t_a,pack3x)
plot(t_a,pack4x)
plot(t_a,pack5x)
plot(t_a,pack6x)
legend('1','2','3','4','5','6')
ylabel('Amlitude')
xlabel('Time in Seconds')
title('Wavelets')
gcf
xlim([100 110])




