%% Extract neural data for screening CCEPs.
% modified from the Kurt script 1-10-2016 by DJC
% modified 4-20-2016 by David to help Larry and Stephen 

%% Constants
close all;clear all;clc
% Z_ConstantsKurtConnectivity;

% changed 3-7-2016 by DJC for CCEP amath project
Z_Constants

addpath c:/users/david/desktop/research/raolab/matlab/code/experiment/BetaTriggeredStim/scripts/ %DJC edit 8/14/2015

%%
sid = input('enter subject ID ','s');

%9ab7ab
switch(sid)
    case '9ab7ab'
        tp = 'D:\Subjects\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim';
        block = 'BetaPhase-3';
        stimChans = [59 60];
        chans = [1:64]; % want to look at all channels, DJC 8-28-2015
        
        % chans = [51 52 53 58 57]; % DJC 8-31-2015, look at channels that were deemed potentially interesting before by Miah/Jared to see if I can see anything
        % chans(ismember(chans, stims)) = []; want to look at stim channels too!
        %%
        %'ecb43e'
    case 'd5cd55'
        % sid = SIDS{2};
        tp = 'D:\Subjects\d5cd55\data\D8\d5cd55_BetaTriggeredStim';
        block = 'Block-49';
        stimChans = [54 62];
        %         chans = [53 61 63];
        chans = [1:64];
        
    case 'c91479'
        % sid = SIDS{3};
        tp = 'D:\Subjects\c91479\data\d7\c91479_BetaTriggeredStim';
        block = 'BetaPhase-14';
        stimChans = [55 56];
        %         chans = [64 63 48];
        chans = [1:64];
        
    case '7dbdec'
        % sid = SIDS{4};
        tp = 'D:\Subjects\7dbdec\data\d7\7dbdec_BetaTriggeredStim';
        block = 'BetaPhase-17';
        stimChans = [11 12];
        %         chans = [4 5 14];
        chans = [1:64];
        
    case '9ab7ab'
        %             sid = SIDS{5};
        tp = 'D:\Subjects\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim';
        block = 'BetaPhase-3';
        stimChans = [59 60];
        %         chans = [51 52 53 58 57];
        chans = [1:64];
        
        % chans = 29;
    case '702d24'
        tp = 'D:\Subjects\702d24\data\d7\702d24_BetaStim';
        block = 'BetaPhase-4';
        stimChans = [13 14];
        %         chans = [4 5 21];
        chans = [1:64];
        %             chans = [36:64];
        
    case 'ecb43e'
        tp = 'D:\Subjects\ecb43e\data\d7\BetaStim';
        block = 'BetaPhase-3';
        stimChans = [56 64];
        chans = [1:64];
        %         chans = [47 55]; want to look at all channels
    case '0b5a2e' % added DJC 7-23-2015
        tp = 'D:\Subjects\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim';
        block = 'BetaPhase-2';
        stimChans = [22 30];
        chans = [1:64];
    case '0b5a2ePlayback' % added DJC 7-23-2015
        tp = 'D:\Subjects\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim';
        block = 'BetaPhase-4';
        stimChans = [22 30];
        chans = [1:64];
        
end
%% load in the trigger data
if strcmp(sid,'0b5a2ePlayback')
    load(fullfile(META_DIR, ['0b5a2e' '_tables.mat']), 'bursts', 'fs', 'stims');
    
    % this was for discovering the delay, now it's known to be about
    % 577869
    %         tic;
    %         [smon, info] = tank.readWaveEvent('SMon', 2);
    %         smon = smon';
    %
    %         fs = info.SamplingRateHz;
    %
    %         stim = tank.readWaveEvent('SMon', 4)';
    %         toc;
    %
    %         tic;
    %         mode = tank.readWaveEvent('Wave', 2)';
    %         ttype = tank.readWaveEvent('Wave', 1)';
    %
    %         beta = tank.readWaveEvent('Blck', 1)';
    %
    %         raw = tank.readWaveEvent('Blck', 2)';
    %
    %         toc;
    
    delay = 577869;
else
    
    % below is for original miah style burst tables
    %         load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');
    % below is for modified burst tables
    load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');
end

% drop any stims that happen in the first 500 milliseconds
stims(:,stims(2,:) < fs/2) = [];

% drop any probe stimuli without a corresponding pre-burst/post-burst
% still want to do this for selecting conditioning - DJC, as this in the
% next step ensures we only select conditioning up to last one before beta
% stim train    bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));
bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));

stims(:, bads) = [];


% adjust stim and burst tables for 0b5a2e playback case

if strcmp(sid,'0b5a2ePlayback')
    
    stims(2,:) = stims(2,:)+delay;
    bursts(2,:) = bursts(2,:) + delay;
    bursts(3,:) = bursts(3,:) + delay;
    
end


% drop any stims that happen in the first 500 milliseconds
stims(:,stims(2,:) < fs/2) = [];



bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));
stims(:, bads) = [];

tank = TTank;
tank.openTank(tp);
tank.selectBlock(block);

% after load in the stim table, switch meta directory to where we will
% store stats table

% META_DIR = 'D:\Output\AMATH582\meta';

% DJC 4-20-2016 - this changes the meta directory and output directory 
Z_ConstantsLarryDavidStephen


%% process each ecog channel individually


% figure

for chan = chans
    %% load in ecog data for that channel
    fprintf('loading in ecog data:\n');
    tic;
    grp = floor((chan-1)/16);
    ev = sprintf('ECO%d', grp+1);
    achan = chan - grp*16;
    fprintf('channel %s',chan)
    
    %         [eco, efs] = tdt_loadStream(tp, block, ev, achan);
    [eco, info] = tank.readWaveEvent(ev, achan);
    efs = info.SamplingRateHz;
    eco = eco';
    
    fac = fs/efs;
    
    toc;
    %% Process Triggers 9-3-2015
    
    pts = stims(3,:)==0;
    ptis = round(stims(2,pts)/fac);
    

    % change presamps and post samps to be what Kurt wanted to look at
    presamps = round(0.1 * efs); % pre time in sec
    postsamps = round(0.3 * efs); % post time in sec
    
    t = (-presamps:postsamps)/efs;
    wins = squeeze(getEpochSignal(eco', ptis-presamps, ptis+postsamps+1));
    
    % normalize the windows to each other, using pre data
    awins = wins-repmat(mean(wins(t<0,:),1), [size(wins, 1), 1]);
    
    pstims = stims(:,pts);
    types = unique(bursts(5,pstims(4,:)));
    
    % using idea of probes from Extracting neural data, <250 ms after the end
    % of the beta burst, AND NOT EQUAL TO NULL
    
    if strcmp('0b5a2e',sid) || strcmp('0b5a2ePlayback',sid)
        
        % this is for 0b5a2e
        probes = pstims(5,:) < .250*fs & bursts(5,pstims(4,:))~=types(2);
    else
        % this is for 9ab7ab (and others)
        probes = pstims(5,:) < .250*fs;
    end
    
    %     keeper = ((pstims(5,:)>(0.25*fs))&(pstims(7,:)>(0.25*fs)));
    keeper = probes;
    
    types = unique(bursts(5,pstims(4,:)));
    
    % DJC - 4-20-2016 - KEEP ALL STIMULI 
    
%     kwins = awins(:,keeper);
kwins = awins;
    
    % added DJC 3/9/2016 to save individual responses, want signals x
    % observations x channels
    ECoGData(:,:,chan) = kwins;
 
end

ECoGDataAverage = mean(ECoGData,2);

% save(fullfile(META_DIR, [sid '_StimulationAndCCEPs.mat']), 't','ECoGData','ECoGDataAverage');

% save(fullfile(META_DIR, [sid '_StatsCCEPhuntNOTNULL.mat']), 'zCell', 't','muCell','muMat','stdErrCell');

