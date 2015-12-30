%% script to convert ECO in matlab file from TDT to Blck with data in all of the channels
% DJC 8/19/2015
% modified DJC 12/28/2015 to look at 0b5a2e, idea is to look at pre and
% post stim resting state - here we are only looking at 64 channels sampled
% at high sampling rate 

%% Constants
Z_Constants;
addpath ./scripts/ %DJC edit 7/17/2015

%% load in the converted Data file of interest - here is POST stim
sid = SIDS{8}; %sid 8 is 0b5a2e 
chans = 1:64;

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
    
    % on first pass, initialize Blck which will have our data to be a zeros
    % matrix of the size of our signal recordings x channels
    if chan == 1
        Blck = zeros(length(eco),length(chans));
    end
    
    Blck(:,chan) = eco;
    
end

%% save it to output directory
save(fullfile(META_DIR, [sid '_postStimRest.mat']),'efs','Blck','-v7.3');


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

for chan = chans
    
    grp = floor((chan-1)/16);
    ev = sprintf('ECO%d', grp+1);
    achan = chan - grp*16;
    
    %         [eco, efs] = tdt_loadStream(tp, block, ev, achan);
    [eco, info] = tank.readWaveEvent(ev, achan);
    efs = info.SamplingRateHz;
    eco = eco(732420:end);
    % on first pass, initialize Blck which will have our data to be a zeros
    % matrix of the size of our signal recordings x channels
    if chan == 1
        Blck = zeros(length(eco),length(chans));
    end
    
    Blck(:,chan) = eco;
    
end

%% save it to output directory
save(fullfile(META_DIR, [sid '_preStimRest.mat']),'efs', 'Blck','-v7.3');

%% look at resting states one by one



figure

    t = (0:size(Blck,1)-1)/efs;
    
for i = 1:size(Blck,2)
    

    plot(1e3*t,1e6*Blck(:,i))
    title(sprintf('Channel %d',i))
    xlabel('Time (ms)')
    ylabel('Amplitude (uV)')
    pause(1)
    
    
end

%% plot ffts like larry

figure

for i = 1:size(Blck,2)
    subplot(8,8,i)
    ft = fft(Blck(:,i));
    plot(abs(ft))
    title(sprintf('Channel %d',i))

    
    
end

subtitle('FFTs')


%% plot xcorrs like larry

figure

for i = 1:size(Blck,2)
    subplot(8,8,i)
    plot(1e3*t,1e6*Blck(:,i))
    title(sprintf('Channel %d',i))

    
    
end

subtitle('Autocorrelations')

