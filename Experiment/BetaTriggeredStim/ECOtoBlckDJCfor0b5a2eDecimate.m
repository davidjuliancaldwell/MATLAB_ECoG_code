%% script to convert ECO in matlab file from TDT to Blck with data in all of the channels
% DJC 8/19/2015
% modified DJC 12/28/2015 to look at 0b5a2e, idea is to look at pre and
% post stim resting state - here we are only looking at 64 channels sampled
% at high sampling rate

% modified by DJC 1-11-2016 to decimate

%% Constants
clear all
close all
cd 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Code\Experiment\BetaTriggeredStim'
Z_ConstantsPLV;
addpath .\scripts\ %DJC edit 7/17/2015

%% load in the converted Data file of interest - here is POST stim
sid = SIDS{8}; %sid 8 is 0b5a2e
chans = 1:64;

% downsampling rate
n = 12;
switch(sid)
    case '0b5a2e'
        % sid = SIDS{1};
        tp = 'D:\Subjects\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim';
        block = 'BetaPhase-5';
        stims = [22 30];
        chans = [23 31]; % these are the channels we thought we saw beta in
        chans = 1:64; % here we want to look at all of the channels to start
end

tank = TTank;
tank.openTank(tp);
tank.selectBlock(block);

for chan = chans
    
    grp = floor((chan-1)/16);
    ev = sprintf('ECO%d', grp+1);
    achan = chan - grp*16;
    
    %         [eco, efs] = tdt_loadStream(tp, block, ev, achan);
    [eco, info] = tank.readWaveEvent(ev, achan);
    efs = info.SamplingRateHz;
    
    fs = efs/n;
    
    ecoDown = decimate(eco,12);
    clear eco;
    % on first pass, initialize Blck which will have our data to be a zeros
    % matrix of the size of our signal recordings x channels
    if chan == 1
        Blck = zeros(length(ecoDown),length(chans));
    end
    
    Blck(:,chan) = ecoDown;
    
end

%% save it to output directory
save(fullfile(META_DIR, [sid '_postStimRestDecimated.mat']),'fs','Blck','-v7.3');


%% DO the same for PRE stim state of 8 minutes
% load in the converted Data file of interest
sid = SIDS{8};
chans = 1:64;

switch(sid)
    case '0b5a2e'
        % sid = SIDS{1};
        tp = 'D:\Subjects\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim';
        block = 'BetaPhase-12'; % this is the PRE stim for 0b5a2e
        stims = [22 30];
        chans = [23 31]; % these are the channels to look at first for beta during beta triggered stim
        chans = 1:64; % we want to start looking at all of the channels
end

tank = TTank;
tank.openTank(tp);
tank.selectBlock(block);

% decimation
n = 12;


for chan = chans
    
    grp = floor((chan-1)/16);
    ev = sprintf('ECO%d', grp+1);
    achan = chan - grp*16;
    
    %         [eco, efs] = tdt_loadStream(tp, block, ev, achan);
    [eco, info] = tank.readWaveEvent(ev, achan);
    efs = info.SamplingRateHz;
    eco = eco(732420:end);
    ecoDown = decimate(eco,n);
    clear eco;
    
    fs = efs/n;
    % on first pass, initialize Blck which will have our data to be a zeros
    % matrix of the size of our signal recordings x channels
    if chan == 1
        Blck = zeros(length(ecoDown),length(chans));
    end
    
    Blck(:,chan) = ecoDown;
    
end

%% save it to output directory
save(fullfile(META_DIR, [sid '_preStimRestDecimated.mat']),'fs', 'Blck','-v7.3');

%% load in post stim

load('D:\Output\BetaTriggeredStim\meta\0b5a2e_postStimRest.mat')

%% load in pre stim

load('D:\Output\BetaTriggeredStim\meta\0b5a2e_preStimRest.mat')

%% look at resting states one by one



figure

t = (0:size(Blck,1)-1)/efs;

for i = 1:size(Blck,2)
    
    figure
    plot(1e3*t,1e6*Blck(:,i))
    title(sprintf('Channel %d',i))
    xlabel('Time (ms)')
    ylabel('Amplitude (uV)')
  
    figure
    xc = xcorr(Blck(:,i),Blck(:,i));
    plot(xc)
%         pause(0.5)
   
    figure
    ft = fft(Blck(:,i));
    loglog(abs(ft))
%     pause(0.5)
    
    
    
end

%% subtract means

BlckMeanSub = bsxfun(@minus, Blck, mean(Blck));

Blck = BlckMeanSub;

%% plot ffts like larry

figure

for i = 1:size(Blck,2)
    subplot(8,8,i)
    ft = fft(Blck(:,i));
    df = efs/length(ft);
    f = (0:(length(ft)-1))*df;
    loglog(abs(ft))
    title(sprintf('Channel %d',i))
    
    
    
    
end

subtitle('FFTs')


%% plot xcorrs like larry

figure

for i = 1:size(Blck,2)
    subplot(8,8,i)
    xc = xcorr(Blck(:,i),Blck(:,i));
    plot(xc)
    title(sprintf('Channel %d',i))
    
    
    
end

subtitle('Autocorrelations')

