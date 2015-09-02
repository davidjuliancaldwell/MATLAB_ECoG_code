%% script to convert ECO in matlab file from TDT to Blck with data in all of the channels
% DJC 8/19/2015

%% Constants
Z_Constants;
addpath ./scripts/ %DJC edit 7/17/2015

%% load in the converted Data file of interest
sid = SIDS{7};
chans = 1:64;

tank = TTank;
tank.openTank('C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\ecb43e\data\d7\BetaStim');
tank.selectBlock('BetaPhase-8');

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
save(fullfile(META_DIR, [sid '_postStimRest.mat']), 'Blck','-v7.3');


%% DO the same for PRE stim state of 8 minutes 
% load in the converted Data file of interest
sid = SIDS{7};
chans = 1:64;

tank = TTank;
tank.openTank('C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\ecb43e\data\d7\BetaStim');
tank.selectBlock('BetaPhase-1');

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
save(fullfile(META_DIR, [sid '_preStimRest.mat']), 'Blck','-v7.3');

