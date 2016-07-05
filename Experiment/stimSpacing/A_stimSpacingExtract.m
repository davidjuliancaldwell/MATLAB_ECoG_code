%% 6-23-2016 - David Caldwell - script to look at stim spacing
% starting with subject 3f2113

%% initialize output and meta dir
% clear workspace
close all; clear all; clc

% set input output working directories
Z_ConstantsStimSpacing;
%CODE_DIR = fullfile(myGetenv('gridlab_dir'));
%scripts_path =  strcat(CODE_DIR,'\Experiment\BetaTriggeredStim\scripts');

% add path for scripts to work with data tanks
addpath('./scripts')

% subject directory, change as needed
SUB_DIR = fullfile(myGetenv('subject_dir'));

%% load in subject

% this is from my z_constants

sid = SIDS{1};

% load in tank
if (strcmp(sid, '3f2113'))
    tank = TTank;
    tankSelect = strcat(SUB_DIR,'\',sid,'\data\data\d6\stimMoving\stimMoving');
    tank.openTank(tankSelect);
    
    % select the block
    tank.selectBlock('stimSpacing-3');
    %  mark stim channels if desired
    stim_chans = input('Input the stim channels as an array e.g. [22 30]');
    % stims = [29 28];
    
    % load in the data, stim info, sampling rates
    tic;
    [data, data_info] = tank.readWaveEvent('Wave');
    [stim, stim_info] = tank.readWaveEvent('Stim');
    toc;
    
    % get sampling rates
    fs_data = data_info.SamplingRateHz;
    fs_stim = stim_info.SamplingRateHz;
    
    % get current delivery
    [Stm0, Stm0_info] = tank.readWaveEvent('Stm0');
    [Sing, Sing_info] = tank.readWaveEvent('Sing');
    
end

%% plot stim

figure
hold on
for i = 1:size(stim,2)
    
    t = (0:length(stim)-1)/fs_stim;
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
t = (0:size(stims,1)-1)/fs_sing;
t = t*1e3;
figure
plot(t,stims)
xlabel('Time (ms');
ylabel('Current to be delivered (mA)')
title('Current to be delivered for all trials')

% delay loks to be 0.2867 ms from below.

%% Plot stims with info from above

stim1 = stim(:,1);
stim1Epoched = squeeze(getEpochSignal(stim1,(bursts(2,:)-1),(bursts(3,:))+1));
t = (0:size(stim1Epoched,1)-1)/fs_stim;
t = t*1e3;
figure
plot(t,stim1Epoched)
xlabel('Time (ms');
ylabel('Voltage (V)');
title('Finding the delay between current output and stim delivery')

% hold on
%
% plot(t,stims)

% get the delay in stim times

delay = round(0.2867*fs_stim/1e3);

% plot the appropriately delayed signal
figure
stimTimesBegin = bursts(2,:)-1+delay;
stimTimesEnd = bursts(3,:)-1+delay;
stim1Epoched = squeeze(getEpochSignal(stim1,stimTimesBegin,stimTimesEnd));
t = (0:size(stim1Epoched,1)-1)/fs_stim;
t = t*1e3;
figure
plot(t,stim1Epoched)
xlabel('Time (ms');
ylabel('Voltage (V)');
title('Stim voltage monitoring with delay added in')



%% extract data

% try and account for delay for the stim times
stimTimes = bursts(2,:)-1+delay;
presamps = round(0.1 * fs_data); % pre time in sec
postsamps = round(0.30 * fs_data); % post time in sec, % modified DJC to look at up to 300 ms after


% sampling rate conversion between stim and data
fac = fs_stim/fs_data;

% find times where stims start in terms of data sampling rate
sts = round(stimTimes / fac);

%% Interpolation from miah's code

% uncomment this if wanting to interpolate, broken right now

% for i = 1:size(data,2)
%     presamps = round(0.025 * fs_data); % pre time in sec
%     postsamps = round(0.125 * fs_data); % post time in sec, % modified DJC to look at up to 300 ms after
%     eco = data(:,i);
%
%     edd = zeros(size(sts));
%     efs = fs_data;
%
%     temp = squeeze(getEpochSignal(eco, sts-presamps, sts+postsamps+1));
%     foo = mean(temp,2);
%     lastsample = round(0.040 * efs);
%     foo(lastsample:end) = foo(lastsample-1);
%
%     last = find(abs(zscore(foo))>1,1,'last');
%     last2 = find(abs(diff(foo))>30e-6,1,'last')+1;
%
%     zc = false;
%
%     if (isempty(last2))
%         if (isempty(last))
%             error ('something seems wrong in the triggered average');
%         else
%             ct = last;
%         end
%     else
%         if (isempty(last))
%             ct = last2;
%         else
%             ct = max(last, last2);
%         end
%     end
%
%     while (~zc && ct <= length(foo))
%         zc = sign(foo(ct-1)) ~= sign(foo(ct));
%         ct = ct + 1;
%     end
%
%     if (ct > max(last, last2) + 0.10 * efs) % marched along more than 10 msec, probably gone to far
%         ct = max(last, last2);
%     end
%
%     % DJC - 8-31-2015 - i believe this is messing with the resizing
%     % in the figures
%     %             subplot(8,8,chan);
%     %             plot(foo);
%     %             vline(ct);
%     %
%
%     % comment this part out for no interpolation
%     for sti = 1:length(sts)
%         win = (sts(sti)-presamps):(sts(sti)+postsamps+1);
%
%         % interpolation approach
%         eco(win(presamps:(ct-1))) = interp1([presamps-1 ct], eco(win([presamps-1 ct])), presamps:(ct-1));
%     end
%
%     data(:,i) = eco;
% end

%% get the data epochs
dataEpoched = squeeze(getEpochSignal(data,sts-presamps,sts+postsamps+1));

% set the time vector to be set by the pre and post samps
t = (-presamps:postsamps)*1e3/fs_data;



%% 6-23-2016
% plot aggregate data for each stim type - THIS ONLY WORKS IF THERE ARE 30
% TOTAL STIM EPOCHS - stim 9 for instance only has 28 total

% chunk out data

% to separate out low and high
k=1:10;
j = 1:10;

figure
for i = 1:64
    hold on
    subplot(8,8,i)
    plot(t,1e6*mean(dataEpoched(:,i,j),3),'m','LineWidth',1)
    
    ylim([-150 150])
    xlim([-100 300])
    title(sprintf('Channel %d',i))
    %     pause(1)
    
    dataEpochedLow(:,i,k) = dataEpoched(:,i,j);
    
end
subtitle('Average traces for all stimulations - means not subtracted - stims 1:10')
xlabel('Time (ms)')
ylabel('Voltage (uV)')

figure
for i = 65:80
    hold on
    subplot(8,8,i-64)
    plot(t,1e6*mean(dataEpoched(:,i,j),3),'m','LineWidth',1)
    
    ylim([-150 150])
    xlim([-100 300])
    title(sprintf('Channel %d',i))
    %     pause(1)
    dataEpochedLow(:,i,k) = dataEpoched(:,i,j);
    
    
end
subtitle('Average traces for all stimulations - means not subtracted - stims 1:10')
xlabel('Time (ms)')
ylabel('Voltage (uV)')

j = 11:20;

figure
for i = 1:64
    hold on
    subplot(8,8,i)
    plot(t,1e6*mean(dataEpoched(:,i,j),3),'m','LineWidth',1)
    
    ylim([-150 150])
    xlim([-100 300])
    title(sprintf('Channel %d',i))
    %     pause(1)
    dataEpochedMid(:,i,k) = dataEpoched(:,i,j);
    
    
end
subtitle('Average traces for all stimulations - means not subtracted stims - stims 11:20')
xlabel('Time (ms)')
ylabel('Amplitude (\muV)')

figure
for i = 65:80
    hold on
    subplot(8,8,i-64)
    plot(t,1e6*mean(dataEpoched(:,i,j),3),'m','LineWidth',1)
    
    ylim([-150 150])
    xlim([-100 300])
    title(sprintf('Channel %d',i))
    %     pause(1)
    dataEpochedMid(:,i,k) = dataEpoched(:,i,j);
    
    
end
subtitle('Average traces for all stimulations - means not subtracted - stims 11:20 ')
xlabel('Time (ms)')
ylabel('Amplitude (\muV)')

j = 21:30;

figure
for i = 1:64
    hold on
    subplot(8,8,i)
    plot(t,1e6*mean(dataEpoched(:,i,j),3),'m','LineWidth',1)
    
    ylim([-150 150])
    xlim([-100 300])
    title(sprintf('Channel %d',i))
    %     pause(1)
    dataEpochedHigh(:,i,k) = dataEpoched(:,i,j);
    
    
end
subtitle('Average traces for all stimulations - means not subtracted - stims 21:30 ' )
xlabel('Time (ms)')
ylabel('Amplitude (\muV)')

figure
for i = 65:80
    hold on
    subplot(8,8,i-64)
    plot(t,1e6*mean(dataEpoched(:,i,j),3),'m','LineWidth',1)
    
    ylim([-150 150])
    xlim([-100 300])
    title(sprintf('Channel %d',i))
    %     pause(1)
    dataEpochedHigh(:,i,k) = dataEpoched(:,i,j);
    
    
end
subtitle('Average traces for all stimulations - means not subtracted - stims 21:30')
xlabel('Time (ms)')
ylabel('Amplitude (\muV)')


%% 6-23-2016 - plot channel of interest

% pick channel
i = 21;
% pick range of stims
j = 1:10;
%j = 11:20;
%j = 21:30;

figure
plot(t,1e6*mean(dataEpoched(:,i,j),3),'m','LineWidth',1)
xlabel('time (ms)')
ylabel('Amplitude (\muV)')
title(['Average for subselected stims for channel ', num2str(i)])

%%
%save(fullfile(OUTPUT_DIR, ['stim_constantV',num2str(stim_chans(1)),'_',num2str(stim_chans(2))]), 'data_info','dataEpoched','dataEpochedHigh','dataEpochedLow','dataEpochedMid','fs_data','fs_sing','fs_stim','Sing','Sing_info','stim','stim_chans','stim_info','t');
save(fullfile(OUTPUT_DIR, ['stim_',num2str(stim_chans(1)),'_',num2str(stim_chans(2))]), 'data_info','dataEpoched','dataEpochedHigh','dataEpochedLow','dataEpochedMid','fs_data','fs_sing','fs_stim','Sing','Sing_info','stim','stim_chans','stim_info','t');
