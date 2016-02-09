%% 1/14/2016 - File by DJC to look at 3x3 stim data

% load in data

close all;clear all;clc

sid = input('What is the subject SID?    ','s');

switch sid
    case '0b5a2e'
        load 'D:\Subjects\0b5a2e\data\d8\0b5a2e_otherStim\0b5a2e_otherStim\Matlab\3x3-2'
end

%% plot stim data 

figure

n = size(Stim.data,2);
l = size(Stim.data,1);


fs = Stim.info.SamplingRateHz;
t = (0:l-1)/fs;

for i = 1:size(Stim.data,2)
    ax(i+1) = subplot(n,1,i);
    plot(t,Stim.data(:,i))
    title(sprintf('Channel %d',i))
    maxChan = max(abs(Stim.data(:,i)));
    sprintf('Maximum voltage for Channel %d is %d',i,maxChan)
end

linkaxes(ax,'xy')
ylabel('Voltage (V)')
xlabel('Time (S)')