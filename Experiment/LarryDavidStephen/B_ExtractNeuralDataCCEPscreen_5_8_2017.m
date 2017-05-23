%% Extract neural data for screening CCEPs.
% modified from the Kurt script 1-10-2016 by DJC
% modified 4-20-2016 by David to help Larry and Stephen
% modified by David 5-8-2017 to make baseline figs for Beta stim

%% Constants
close all;clear all;clc
% Z_ConstantsKurtConnectivity;


% % looping through it! - DJC
% for i = 2:9

% changed 3-7-2016 by DJC for CCEP amath project
Z_Constants

addpath ../BetaTriggeredStim/scripts/ %DJC edit 8/14/2015
SUB_DIR = fullfile(myGetenv('subject_dir'));

%%
sid = input('enter subject ID ','s');

%9ab7ab
% sid = SIDS{i};
switch(sid)
    
    case '8adc5c'
        % sid = SIDS{1};
        tp = strcat(SUB_DIR,'\8adc5c\data\D6\8adc5c_BetaTriggeredStim');
        block = 'Block-67';
        stims = [31 32];
        chans = [1:64];
        
    case 'd5cd55'
        % sid = SIDS{2};
        % sid = SIDS{2};
        tp = strcat(SUB_DIR,'\d5cd55\data\D8\d5cd55_BetaTriggeredStim');
        block = 'Block-49';
        stims = [54 62];
        stimChans = [54 62];
        %         chans = [53 61 63];
        betaChan = 53;
        chans = [1:64];
        
    case 'c91479'
        % sid = SIDS{3};
        tp = strcat(SUB_DIR,'\c91479\data\d7\c91479_BetaTriggeredStim');
        block = 'BetaPhase-14';
        stims = [55 56];
        stimChans = [55 56];
        %         chans = [64 63 48];
        betaChan = 64;
        chans = [1:64];
        
    case '7dbdec'
        % sid = SIDS{4};
        tp = strcat(SUB_DIR,'\7dbdec\data\d7\7dbdec_BetaTriggeredStim');
        block = 'BetaPhase-17';
        stims = [11 12];
        stimChans = [11 12];
        %         chans = [4 5 14];
        betaChan = 4;
        
        chans = [1:64];
        
    case '9ab7ab'
        %             sid = SIDS{5};
        %             sid = SIDS{5};
        tp = strcat(SUB_DIR,'\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim');
        block = 'BetaPhase-3';
        stims = [59 60];
        stimChans = [59 60];
        %         chans = [51 52 53 58 57];
        chans = [1:64];
        betaChan = 51;
        % chans = 29;
    case '702d24'
        tp = strcat(SUB_DIR,'\702d24\data\d7\702d24_BetaStim');
        block = 'BetaPhase-4';
        stims = [13 14];
        stimChans = [13 14];
        %         chans = [4 5 21];
        chans = [1:64];
        betaChan = 5;
        %             chans = [36:64];
        
    case 'ecb43e'
        tp = strcat(SUB_DIR,'\ecb43e\data\d7\BetaStim');
        block = 'BetaPhase-3';
        stims = [56 64];
        stimChans = [56 64];
        chans = [1:64];
        betaChan = 55;
        %         chans = [47 55]; want to look at all channels
    case '0b5a2e' % added DJC 7-23-2015
        tp = strcat(SUB_DIR,'\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim');
        block = 'BetaPhase-2';
        stims = [22 30];
        stimChans = [22 30];
        chans = [1:64];
        betaChan = 31;
    case '0b5a2ePlayback' % added DJC 7-23-2015
        tp = strcat(SUB_DIR,'\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim');
        block = 'BetaPhase-4';
        stims = [22 30];
        stimChans = [22 30];
        chans = [1:64];
        
    case '0a80cf' % added DJC 5-24-2016
        tp = strcat(SUB_DIR,'\0a80cf\data\d10\0a80cf_BetaStim\0a80cf_BetaStim');
        block = 'BetaPhase-4';
        stims = [27 28];
        stimChans = [27 28];
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

for chan = chans
    %% load in ecog data for that channel
    fprintf('loading in %s ecog data:\n',sid);
    tic;
    grp = floor((chan-1)/16);
    ev = sprintf('ECO%d', grp+1);
    achan = chan - grp*16;
    fprintf('channel %d \n',chan)
    
    %         [eco, efs] = tdt_loadStream(tp, block, ev, achan);
    [eco, info] = tank.readWaveEvent(ev, achan);
    efs = info.SamplingRateHz;
    eco = eco';
    
    fac = fs/efs;
    
    
    
    toc;
    
    %% 6-16-2016 - Do the notch on ecb43e
    if strcmp(sid,'ecb43e')
        %% preprocess eco
        %             presamps = round(0.050 * efs); % pre time in sec
        presamps = round(0.025 * efs); % pre time in sec
        
        % miah had 0.120
        postsamps = round(0.120 * efs); % post time in sec, % modified DJC to look at up to 300 ms after
        
        sts = round(stims(2,:) / fac);
        edd = zeros(size(sts));
        
        
        temp = squeeze(getEpochSignal(eco', sts-presamps, sts+postsamps+1));
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
%         
%         if (ct > max(last, last2) + 0.10 * efs) % marched along more than 10 msec, probably gone to far
%             ct = max(last, last2);
%         end
        % djc try 5-9-2017 try 15 
         if (ct > max(last, last2) + 0.15 * efs) % marched along more than 15 msec, probably gone to far
             ct = max(last, last2);
         end
        

        %         % DJC - 8-31-2015 - i believe this is messing with the resizing
        %         % in the figures
        %         %             subplot(8,8,chan);
        %         %             plot(foo);
        %         %             vline(ct);
        %         %
        for sti = 1:length(sts)
            win = (sts(sti)-presamps):(sts(sti)+postsamps+1);
            
            %             interpolation approach
            eco(win(presamps:(ct-1))) = interp1([presamps-1 ct], eco(win([presamps-1 ct])), presamps:(ct-1));
        end
        % ORIGINAL ORDER WAS bandpass, notch
        % try reversing it DJC, 2/11/2016
        
        %                 eco = toRow(bandpass(eco, 1, 40, efs, 4, 'causal'));
        % original notch below
        %                 eco = toRow(notch(eco, 60, efs, 2, 'causal'));
        
        % JUST TRY NOTCH AT 60 120 180 240
        % 2-26-2016 - my attempt for ecb43e
        eco = toRow(notch(eco, [60 120 180 240], efs, 2, 'causal'));
        %
        %
    end
    %% Process Triggers 9-3-2015
    
    pts = stims(3,:)==0;
    
    % 0a80cf only had conditioning
    
    if strcmp(sid,'0a80cf');
        pts = stims(3,:)==1;
    end
    
    ptis = round(stims(2,pts)/fac);
    
    % change presamps and post samps to be what Kurt wanted to look at
    presamps = round(0.1 * efs); % pre time in sec
    postsamps = round(0.15 * efs); % post time in sec
    
    t = (-presamps:postsamps)/efs;
    wins = squeeze(getEpochSignal(eco', ptis-presamps, ptis+postsamps+1));
    
    % normalize the windows to each other, using pre data
    awins = wins-repmat(mean(wins(t<0,:),1), [size(wins, 1), 1]);
    
    pstims = stims(:,pts);
    
    if ~strcmp('0a80cf',sid)
        types = unique(bursts(5,pstims(4,:)));
    end
    
    % using idea of baselines
    
    
    baselines = pstims(5,:) > 2 * fs;
    
    keeper = baselines;
    
    if ~strcmp('0a80cf',sid)
        types = unique(bursts(5,pstims(4,:)));
    end
    
    % DJC - 4-20-2016 - KEEP ALL STIMULI
    
    kwins = awins(:,keeper);
    kwins = awins;
    clear awins
    % added DJC 3/9/2016 to save individual responses, want signals x
    % observations x channels
    ECoGData(:,:,chan) = kwins;
    clear kwins
end

ECoGDataAverage = squeeze(mean(ECoGData,2));

save(fullfile(OUTPUT_DIR, [sid '_baselineCCEPs.mat']), 't','ECoGData','ECoGDataAverage','-v7.3');

% close all; clearvars -except i
% end
% save(fullfile(META_DIR, [sid '_StatsCCEPhuntNOTNULL.mat']), 'zCell', 't','muCell','muMat','stdErrCell');
%%
totalFig = figure;
totalFig.Units = 'inches';
totalFig.Position = [   10.4097    3.4722   13.2708   10.4514];
CT = cbrewer('qual','Accent',8);
CT = flipud(CT);

for idx=1:64
    smplot(8,8,idx,'axis','on')
    
    if ismember(idx,stimChans)
        plot(1e3*t,1e6*ECoGDataAverage(:,idx),'Color',CT(3,:),'LineWidth',2)
        title([num2str(idx)],'Color',CT(3,:))
    elseif ismember(idx,betaChan)
        plot(1e3*t,1e6*ECoGDataAverage(:,idx),'Color',CT(2,:),'LineWidth',2)
        title([num2str(idx)],'Color',CT(2,:))
    else
        plot(1e3*t,1e6*ECoGDataAverage(:,idx),'Color',CT(1,:),'LineWidth',2)
        title([num2str(idx)],'color',CT(1,:))
    end
    
    axis off
    axis tight
    xlim([-10 50])
    ylim([-130 130])
        vline(0)

    %subtitle(['Baseline CCEPs by Channel']);


end
    obj = scalebar;
    obj.XLen = 25;              %X-Length, 10.
obj.XUnit = 'ms';            %X-Unit, 'm'.
obj.YLen = 100;
obj.YUnit = '\muV';

obj.Position = [20,-130];
obj.hTextX_Pos = [5,-30]; %move only the LABEL position
obj.hTextY_Pos =  [30,-15];
obj.hLineY(2).LineWidth = 5;
obj.hLineY(1).LineWidth = 5;
obj.hLineX(2).LineWidth = 5;
obj.hLineX(1).LineWidth = 5;
obj.Border = 'LR';          %'LL'(default), 'LR', 'UL', 'UR'

