%% 7-14-2016 - David Caldwell - script to look at stim spacing
% requires getEpochSignal.m , subtitle.m , numSubplots.m , vline.m
% GRAPHICS SHOULD WORK FOR BEFORE MATLAB 2014b

%% initialize output and meta dir
% clear workspace
close all; clear all; clc


% load in the datafile of interest!
% have to have a value assigned to the file to have it wait to finish
% loading...mathworks bug

structureData = uiimport('-file');
Sing = structureData.Sing;
Stim = structureData.Stim;
Stm0 = structureData.Stm0;
Wave = structureData.Wave;
Eco1 = structureData.ECO1;
Eco2 = structureData.ECO2;
Eco3 = structureData.ECO3;
Eco4 = structureData.ECO4;

Wave.info = structureData.ECO1.info; 

%%
% ui box for input for stimulation channels
prompt = {'how many channels did we record from? e.g 48 ', 'what were the stimulation channels? e.g 28 29 ', 'how long before each stimulation do you want to look? in ms e.g. 1', 'how long after each stimulation do you want to look? in ms e.g 5'};
dlg_title = 'StimChans';
num_lines = 1;
defaultans = {'48','28 29','1','5'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
numChans = str2num(answer{1});
chans = str2num(answer{2});
preTime = str2num(answer{3});
postTime = str2num(answer{4});

%%
% first and second stimulation channel
stim_1 = chans(1);
stim_2 = chans(2);


% get sampling rates
fs_data = Wave.info.SamplingRateHz;
fs_stim = Stim.info.SamplingRateHz;

% stim data
stim = Stim.data;

% current data
sing = Sing.data;

% recording data
data = [Eco1.data Eco2.data Eco3.data Eco4.data];


%% plot stim channels if interested

prompt = {'plot intermediate figures that show stim voltage, currents, and delays? "y" or "n" '};
dlg_title = 'StimChans';
num_lines = 1;
defaultans = {'y'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
plotIt = answer(1);

if strcmp(plotIt,'y')
    figure;
    hold on;
    for i = 1:size(stim,2)
        
        t = (0:length(stim)-1)/fs_stim;
        subplot(2,2,i);
        plot(t*1e3,stim(:,i));
        title(sprintf('Channel %d',i));
        
        
    end
    
    
    xlabel('Time (ms)');
    ylabel('Amplitude (V)');
    
    subtitle('Stimulation Channels');
end

%% Sing looks like the wave to be delivered, with amplitude in uA


% build a burst table with the timing of stimuli
bursts = [];

% first channel of current
Sing1 = sing(:,1);
fs_sing = Sing.info.SamplingRateHz;

samplesOfPulse = round(2*fs_stim/1e3);

Sing1Mask = Sing1~=0;
dmode = diff([0 Sing1Mask' 0 ]);

dmode(end-1) = dmode(end);

bursts(2,:) = find(dmode==1);
bursts(3,:) = find(dmode==-1);

singEpoched = squeeze(getEpochSignal(Sing1,(bursts(2,:)-1),(bursts(3,:))+1));
t = (0:size(singEpoched,1)-1)/fs_sing;
t = t*1e3;

if strcmp(plotIt,'y')
    
    figure
    plot(t,singEpoched)
    xlabel('Time (ms)');
    ylabel('Current to be delivered (\muA)')
    title('Current to be delivered for all trials')
end


%% Plot stims with info from above, and find the delay!

stim1stChan = stim(:,1);
stim1Epoched = squeeze(getEpochSignal(stim1stChan,(bursts(2,:)-1),(bursts(3,:))+120));
t = (0:size(stim1Epoched,1)-1)/fs_stim;
t = t*1e3;

if strcmp(plotIt,'y')
    
    figure
    plot(t,stim1Epoched)
    xlabel('Time (ms)');
    ylabel('Voltage (V)');
    title('Finding the delay between current output and stim delivery')
    
end

% get the delay in stim times - looks to be 7 samples or so
delay = round(0.2867*fs_stim/1e3);


% plot the appropriately delayed signal
if strcmp(plotIt,'y')
    stimTimesBegin = bursts(2,:)-1+delay;
    stimTimesEnd = bursts(3,:)-1+delay+120;
    stim1Epoched = squeeze(getEpochSignal(stim1stChan,stimTimesBegin,stimTimesEnd));
    t = (0:size(stim1Epoched,1)-1)/fs_stim;
    t = t*1e3;
    figure
    plot(t,stim1Epoched)
    xlabel('Time (ms');
    ylabel('Voltage (V)');
    title('Stim voltage monitoring with delay added in')
end



%% extract data

% try and account for delay for the stim times
stimTimes = bursts(2,:)-1+delay;

% DJC 7-7-2016, changed presamps and postsamps to be user defined
presamps = round(preTime/1000 * fs_data); % pre time in sec
postsamps = round(postTime/1000 * fs_data); % post time in sec,


% sampling rate conversion between stim and data
fac = fs_stim/fs_data;

% find times where stims start in terms of data sampling rate
sts = round(stimTimes / fac);


% looks like there's an additional 14 sample delay between the stimulation being set to
% be delivered....and the ECoG recording. which would be 2.3 ms?

delay2 = 14;
sts = round(stimTimes / fac) + delay2;
%sts = round(stimTimes / fac);

%% get the data epochs
dataEpoched = squeeze(getEpochSignal(data,sts-presamps,sts+postsamps+1));

% set the time vector to be set by the pre and post samps
t = (-presamps:postsamps)*1e3/fs_data;


%% make the decision to scale it

% ui box for input
prompt = {'sscale the y axis to the maximum stim pulse value? "y" or "n" '};
dlg_title = 'Scale';
num_lines = 1;
defaultans = {'n'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
scaling = answer{1};

if strcmp(scaling,'y')
    maxVal = max(dataEpoched(:));
    minVal = min(dataEpoched(:));
end


%% plot individual trials for each condition on a different graph

labels = max(singEpoched);
uniqueLabels = unique(labels);

% intialize counter for plotting
k = 1;

% make vector of stim channels
stimChans = [stim_1 stim_2];

% determine number of subplot
subPlots = numSubplots(numChans);
p = subPlots(1);
q = subPlots(2);

% plot each condition separately e.g. 1000 uA, 2000 uA, and so on

for i=uniqueLabels
    figure;
    dataInterest = dataEpoched(:,:,labels==i);
    for j = 1:numChans
        subplot(p,q,j);
        plot(t,squeeze(dataInterest(:,j,:)));
        xlim([min(t) max(t)]);
        
        % change y axis scaling if necessary
        if strcmp(scaling,'y')
            ylim([minVal maxVal]);
        end
        
        % put a box around the stimulation channels of interest if need be
        if ismember(j,stimChans)
            ax = gca;
            set(ax,'Box','on');
            set(ax,'Xcolor','red')
            set(ax,'Ycolor','red')
            set(ax,'LineWidth',2)
            title(num2str(j),'color','red');
            
        else
            title(num2str(j));
            
        end
        vline(0);
        
    end
    
    % label axis
    xlabel('time in ms');
    ylabel('voltage in V');
    subtitle(['Individual traces - Current set to ',num2str(uniqueLabels(k)),' \muA']);
    
    
    % get cell of raw values, can use this to analyze later
    dataRaw{k} = dataInterest;
    
    % get averages to plot against each for later
    % cell function, can use this to analyze later
    dataAvgs{k} = mean(dataInterest,3);
    
    
    
    %increment counter
    k = k + 1;
    
    
end

%% plot averages for 3 conditions on the same graph

% this is to plot different colored lines


colorOrder = [         0    0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840];


k = 1;
figure;
for k = 1:length(dataAvgs)
    
    tempData = dataAvgs{k};
    
    for j = 1:numChans
        s = subplot(p,q,j);
        plot(t,squeeze(tempData(:,j)),'linewidth',2,'color',colorOrder(k,:));
        hold on;
        xlim([min(t) max(t)]);
        
        
        % change y axis scaling if necessary
        if strcmp(scaling,'y')
            ylim([minVal maxVal]);
        end
        
        
        if ismember(j,stimChans)
            ax = gca;
            set(ax,'Box','on');
            set(ax,'Xcolor','red')
            set(ax,'Ycolor','red')
            set(ax,'LineWidth',2)
            title(num2str(j),'color','red')
            
        else
            title(num2str(j));
            
        end
        
        vline(0);
        
    end
    gcf;
end
xlabel('time in ms');
ylabel('voltage in V');
subtitle(['Averages for all conditions']);
legLabels = {[num2str(uniqueLabels(1))]};

k = 2;
if length(uniqueLabels>1)
    for i = uniqueLabels(2:end)
        legLabels{end+1} = [num2str(uniqueLabels(k))];
        k = k+1;
    end
end

legend(s,legLabels);