%% 12-22-2015 - File to demonstrate to Larry how Im looking at broca's 

%% load in moreRawDataBrocas.mat

load('moreRawDataBrocas.mat');


%% plot stim

figure
hold on
for i = 1:size(stim,2)
    
    t = (1:length(stim))/fs_stim;
    subplot(2,2,i)
    plot(t*1e3,stim(:,i))
    title(sprintf('Channel %d',i))
    
    
end


xlabel('Time (ms)')
ylabel('Amplitude (V)')

subtitle('Stimulation Channels')

%% Sing looks like the wave to be delivered, with amplitude in uA
% Try working from this

% build a burst table with the timing of stimuli
bursts = [];

Sing1 = Sing(:,1);
fs_sing = Sing_info.SamplingRateHz;

samplesOfPulse = round(2*fs_stim/1e3);



% trying something like A_BuildStimTables from BetaStim


Sing1Mask = Sing1~=0;
dmode = diff([0 Sing1Mask' 0 ]);


dmode(end-1) = dmode(end);


bursts(2,:) = find(dmode==1);
bursts(3,:) = find(dmode==-1);

stims = squeeze(getEpochSignal(Sing1,(bursts(2,:)-1),(bursts(3,:))+1));
t = (1:size(stims,1))/fs_sing;
t = t*1e3;
figure
plot(t,stims)
xlabel('Time (ms');

%% Plot stims with info from above

stim1 = stim(:,1);
stim1Epoched = squeeze(getEpochSignal(stim1,(bursts(2,:)-1),(bursts(3,:))+1));
t = (1:size(stim1Epoched,1))/fs_stim;
t = t*1e3;
figure
plot(t,stim1Epoched)
xlabel('Time (ms');

% hold on
%
% plot(t,stims)

delay = round(0.3277*fs_stim/1e3);

%% extract data
stimTimes = bursts(2,:)-1+delay;
presamps = round(0.025 * fs_data); % pre time in sec
postsamps = round(0.30 * fs_data); % post time in sec, % modified DJC to look at up to 300 ms after

fac = fs_stim/fs_data;

sts = round(stimTimes / fac);

dataEpoched = squeeze(getEpochSignal(data,sts-presamps,sts+postsamps+1));
t = ((1:size(dataEpoched,1))*1e3/fs_data);

% look at mean

dataEpochedMean = mean(dataEpoched,3);

%% this is to plot the aggregate data

figure
for i = 1:64
    hold on
    subplot(8,8,i)
    plot(t,1e6*dataEpochedMean(:,i))
    
    ylim([-50 50])
    xlim([0 150])
    title(sprintf('Channel %d',i))
    %     pause(1)
    
end
subtitle('Average traces for all stimulations - means not subtracted')
xlabel('Time (ms)')
ylabel('Voltage (uV)')

figure
for i = 65:128
    hold on
    subplot(8,8,i-64)
    plot(t,1e6*dataEpochedMean(:,i))
    
    ylim([-50 50])
    xlim([0 150])
    title(sprintf('Channel %d',i))
    %     pause(1)
    
end
subtitle('Average traces for all stimulations - means not subtracted ')
xlabel('Time (ms)')
ylabel('Voltage (uV)')



%% This is to plot the individual traces
figure
for i = 1:64
    hold on
    subplot(8,8,i)
    plot(t,1e6*squeeze(dataEpoched(:,i,:)))
    
    ylim([-50 50])
    xlim([0 150])
    title(sprintf('Channel %d',i))
    %     pause(1)
    
end
subtitle('Individual traces for all stimulations - means not subtracted')
xlabel('Time (ms)')
ylabel('Voltage (uV)')

figure
for i = 65:128
    hold on
    subplot(8,8,i-64)
    plot(t,1e6*squeeze(dataEpoched(:,i,:)))
    
    ylim([-50 50])
    xlim([0 150])
    title(sprintf('Channel %d',i))
    %     pause(1)
    
end
subtitle('Individual traces for all stimulations - means not subtracted')
xlabel('Time (ms)')
ylabel('Voltage (uV)')

%% means before subtracted


% normalize the windows to each other, using pre data

dataEpoched = squeeze(getEpochSignal(data,sts-presamps,sts+postsamps+1));

for i = 1:size(dataEpoched,2)
    
    dataEpochedSub(:,i,:) = dataEpoched(:,i,:)-repmat(mean(dataEpoched(t<25,i,:),1), [size(dataEpoched, 1), 1]);

end
% look at mean

dataEpochedMeanSub = mean(dataEpochedSub,3);

%% plot means subtracted

%% this is to plot the aggregate data

figure
for i = 1:64
    hold on
    subplot(8,8,i)
    plot(t,1e6*dataEpochedMeanSub(:,i))
    
    ylim([-50 50])
    xlim([0 150])
    title(sprintf('Channel %d',i))
    %     pause(1)
    
end
subtitle('Individual traces for all stimulations - means subtracted')
xlabel('Time (ms)')
ylabel('Voltage (uV)')

figure
for i = 65:128
    hold on
    subplot(8,8,i-64)
    plot(t,1e6*dataEpochedMeanSub(:,i))
    
    ylim([-50 50])
    xlim([0 150])
    title(sprintf('Channel %d',i))
    %     pause(1)
    
end
subtitle('Individual traces for all stimulations - means subtracted')
xlabel('Time (ms)')
ylabel('Voltage (uV)')



%% This is to plot the individual traces
figure
for i = 1:64
    hold on
    subplot(8,8,i)
    plot(t,1e6*squeeze(dataEpochedSub(:,i,:)))
    
    ylim([-50 50])
    xlim([0 150])
    title(sprintf('Channel %d',i))
    %     pause(1)
    
end
subtitle('Individual traces for all stimulations - means subtracted')
xlabel('Time (ms)')
ylabel('Voltage (uV)')

figure
for i = 65:128
    hold on
    subplot(8,8,i-64)
    plot(t,1e6*squeeze(dataEpochedSub(:,i,:)))
    
    ylim([-50 50])
    xlim([0 150])
    title(sprintf('Channel %d',i))
    %     pause(1)
    
end
subtitle('Individual traces for all stimulations - means subtracted')
xlabel('Time (ms)')
ylabel('Voltage (uV)')
