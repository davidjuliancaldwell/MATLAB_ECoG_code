%% 12-18-2015 - script to look at Broca's area stimulation
% starting with subject 0b5a2e

%% initialize output and meta dir
close all; clear all; clc
Z_ConstantsBrocas;
addpath c:/users/david/desktop/research/RaoLab/MATLAB/Code/Experiment/BetaTriggeredStim/scripts

%% load in subject

sid = SIDS{1};

if (strcmp(sid, '0b5a2e'))
    tank = TTank;
    tank.openTank('D:\Subjects\0b5a2e\data\d8\0b5a2e_otherStim\0b5a2e_otherStim');
    tank.selectBlock('brocas-1');
    stims = [28 36];
    badChans = [20 24 28]; % unplugged channels
    
    tic;
    [data, data_info] = tank.readWaveEvent('Wave');
    [stim, stim_info] = tank.readWaveEvent('Stim');
    toc;
    
    
    fs_data = data_info.SamplingRateHz;
    fs_stim = stim_info.SamplingRateHz;
    
    [Stm0, Stm0_info] = tank.readWaveEvent('Stm0');
    [Sing, Sing_info] = tank.readWaveEvent('Sing');
    
end

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

%Another attempt to dissect things
%
% timeOfStim = find(Sing1Mask>0);
%
% differenceTimeOfStim = diff(timeOfStim);
% distBetween = find(differenceTimeOfStim>1);
% sampleInd = timeOfStim(distBetween);

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

%% Interpolation from miah's code

for i = 1:size(data,2)
    presamps = round(0.025 * fs_data); % pre time in sec
    postsamps = round(0.125 * fs_data); % post time in sec, % modified DJC to look at up to 300 ms after
    eco = data(:,i);
    
    edd = zeros(size(sts));
    efs = fs_data;
    
    temp = squeeze(getEpochSignal(eco, sts-presamps, sts+postsamps+1));
    foo = mean(temp,2);
    lastsample = round(0.040 * efs);
    foo(lastsample:end) = foo(lastsample-1);
    
    last = find(abs(zscore(foo))>1,1,'last');
    last2 = find(abs(diff(foo))>30e-6,1,'last')+1;
    
    zc = false;
    
    if (isempty(last2))
        if (isempty(last))
            error ('something seems wrong in the triggered average');
        else
            ct = last;
        end
    else
        if (isempty(last))
            ct = last2;
        else
            ct = max(last, last2);
        end
    end
    
    while (~zc && ct <= length(foo))
        zc = sign(foo(ct-1)) ~= sign(foo(ct));
        ct = ct + 1;
    end
    
    if (ct > max(last, last2) + 0.10 * efs) % marched along more than 10 msec, probably gone to far
        ct = max(last, last2);
    end
    
    % DJC - 8-31-2015 - i believe this is messing with the resizing
    % in the figures
    %             subplot(8,8,chan);
    %             plot(foo);
    %             vline(ct);
    %
    for sti = 1:length(sts)
        win = (sts(sti)-presamps):(sts(sti)+postsamps+1);
        
        % interpolation approach
        eco(win(presamps:(ct-1))) = interp1([presamps-1 ct], eco(win([presamps-1 ct])), presamps:(ct-1));
    end
    
    data(:,i) = eco;
end

%%
dataEpoched = squeeze(getEpochSignal(data,sts-presamps,sts+postsamps+1));
t = ((1:size(dataEpoched,1))*1e3/fs_data);

% look at mena

dataEpochedMean = mean(dataEpoched,3);

%% this is to plot the aggregate data

figure
for i = 1:64
    hold on
    subplot(8,8,i)
    plot(t,1e6*dataEpochedMean(:,i),'m','LineWidth',2)
    
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
    plot(t,1e6*dataEpochedMean(:,i),'m','LineWidth',2)
    
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
    plot(t,1e6*dataEpochedMeanSub(:,i),'m','LineWidth',2)
    
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
    plot(t,1e6*dataEpochedMeanSub(:,i),'m','LineWidth',2)
    
    ylim([-50 50])
    xlim([0 150])
    title(sprintf('Channel %d',i))
    %     pause(1)
    
end
subtitle('Individual traces for all stimulations - means subtracted')
xlabel('Time (ms)')
ylabel('Voltage (uV)')

%% plot one at a time

figure

for i = 1:128

    plot(t,1e6*dataEpochedMeanSub(:,i),'m','LineWidth',2);

    %     xlim(1e3*[min(t) max(t)]);
    %     yl = ylim;
    %     yl(1) = min(-10, max(yl(1),-120));
    %     yl(2) = max(10, min(yl(2),100));
    %     ylim(yl);
    ylim([-100 100])
    hold on
%     vline(0);

    title(sprintf('Chan %d', i))
    %
    %     xlabel('time (ms)');
    %     ylabel('ECoG (uV)');
    %
    %     title(sprintf('CCEP, Channel %d', chan))
    pause(1)
    clf
    
    
end

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


%% heat map

figure
for i = 1:64
    hold on
    subplot(8,8,i)
    LinePlotHeatMapFunction(t,1e6*squeeze(dataEpoched(:,i,:)));
    
    ylim([-50 50])
    xlim([0 150])
    title(sprintf('Channel %d',i))
    %     pause(1)
    
end
subtitle('Individual traces for all stimulations - means not subtracted')
xlabel('Time (ms)'); ylabel('Amplitude (\muV)');

figure
for i = 65:128
    hold on
    subplot(8,8,i-64)
    LinePlotHeatMapFunction(t,1e6*squeeze(dataEpoched(:,i,:)));
    
    ylim([-50 50])
    xlim([0 150])
    title(sprintf('Channel %d',i))
    %     pause(1)
    
end
subtitle('Individual traces for all stimulations - means not subtracted')
xlabel('Time (ms)'); ylabel('Amplitude (\muV)');

