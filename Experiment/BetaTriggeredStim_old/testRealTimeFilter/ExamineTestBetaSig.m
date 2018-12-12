%% DJC 5-11-2017
% examine testing beta signal
% input of about 15 Hz, set RMS,
% ECO1.data(:,1) has the raw input signal
% Wave.data(:,4) has the beta signal
close all;clear all;clc
load('G:\My Drive\whiteMatterTestFunctions\betaStimTest_WMsweep.mat')

%%
% example find phase difference 
% peak to peak difference = 3028-3019 in ms @ 13 Hz
freq = 13;
timeDelay = (3027-3018)/1e3;
phaseDiffRad = timeDelay*freq*2*pi
phaseDiffDeg = phaseDiffRad*180/pi
%%
a = ECO1.data(:,1);
figure
fs1 = ECO1.info.SamplingRateHz;

t1 = 1e3*[0:length(a)-1]/fs1;

plot(t1,a)
b = Wave.data(:,3);

figure
plot(b)
c = [0; decimate(b,2)]; % decimate because it's stored at double the rate of Eco

plot(t1,a)
hold on
plot(t1,c)


d = SMon.data(:,2);
% figure
% plot(d)

timeStamps = find(d>0)/2;
timeStamps_c = 1e3*((timeStamps)/fs1);
vline([timeStamps_c])
xlabel('ms')

figure
plot(a)
hold on
plot(c)
vline([timeStamps])
xlabel('samples')

%% find peaks 8-9-2017 

[max,ind] = findpeaks(a,fs1,'minpeakdistance',0.04,'minpeakheight',0);
[max_2,ind_2] = findpeaks(c,fs1,'minpeakdistance',0.04,'minpeakheight',0);


%%
clear all
load('G:\My Drive\BetaStim-2_dummySig.mat')
%%
a = ECO1.data(:,1);
figure
plot(a)
b = Wave.data(:,3);
fs1 = ECO1.info.SamplingRateHz;
fs2 = Wave.info.SamplingRateHz;
d = SMon.data(:,2);

figure
plot(b)
c = decimate(b,2); % decimate because it's stored at double the rate of Eco

t1 = 1e3*[0:length(c)-1]/fs1;
fig1 = figure;
plot(t1,a,'linewidth',2)
hold on
plot(t1,c,'linewidth',2)
timeStamps = find(d>0);
timeStamps = 1e3*((timeStamps/2)/fs1);
vline([timeStamps],'k:');

legend({'Raw Signal','Filtered Signal','Stimulation Trigger'})
xlabel('time (ms)')
ylabel('amplitude')
set(gca,'fontsize', 14)
title('Operation of Real Time Filtering with Stimulation Blanking')
fig1.Position = [447.6667 786.3333 1408 420];
xlim([1.0e5*0.9590 1.0e5*1.0268]);
ylim([-0.09 0.09]);

%% find peaks 8-9-2017 

[max,ind] = findpeaks(a,fs1,'minpeakdistance',0.04,'minpeakheight',0.01);
[max_2,ind_2] = findpeaks(c,fs1,'minpeakdistance',0.04,'minpeakheight',0.01);

% add on seven samples for stim delay 
samps_add = round(1e3*7/fs2);
ind = ind + samps_add;
ind_2 = ind_2 + samps_add;

inds_raw = 1e3*(ind(ind> 0.025 & ind < 142.5));
inds_filt = 1e3*(ind_2(ind_2> 0.025 & ind_2 < 142.5));

% figure
% plot(t1,a)

% hold on
% plot(t1,c)
% vline(inds_raw)
% vline(inds_filt,'g')
%%
inds_raw = inds_raw(inds_raw>2.6e4);
inds_filt = inds_filt(inds_filt>2.6e4);
figure
plot(t1(1e3*t1>2.6e4),a(1e3*t1>2.6e4))
hold on
plot(t1(1e3*t1>2.6e4),c(1e3*t1>2.6e4))
vline(inds_filt)
vline(inds_raw,'b')


phase_diff = inds_raw-inds_filt;

%%

% figure
% plot(d)

e = Svis.data(:,1);
f = Svis.data(:,2);

timeStamps = find(d>0);
timeStamps = 1e3*((timeStamps)/fs2);
vline([timeStamps])
t2 = 1e3*[0:length(e)-1]/fs2;

figure
hold on
plot(t2,b,'linewidth',2)
plot(t2,f,'linewidth',2)
vline([timeStamps],'k:');

legend({'Filtered Signal','Raw signal','Stimulation Trigger'})
xlabel('time (ms)')
ylabel('amplitude')
set(gca,'fontsize', 14)
title('Operation of Real Time Filtering with Stimulation Blanking')
%%

stim = SMon.data(:,4);
figure
plot(t2,stim)

