%% 12-9-2015 - Script to load and process in Pre and Post Stimulation Resting data
% written by DJC

%% Constants
Z_ConstantsPrePost;
addpath ./scripts/ %DJC edit 7/20/2015;

%% parameters

% need to be fixed to be nonspecific to subject
% SIDS = SIDS(2:end);
SIDS = SIDS(6);

for idx = 1:length(SIDS)
    sid = SIDS{idx};
    %DJC edited 7/20/2015 to fix tp paths
    switch(sid)
        case '8adc5c'
            % sid = SIDS{1}; NO GOOD
            tp = 'D:\Subjects\8adc5c\data\D6\8adc5c_BetaTriggeredStim';
            blockPre = 'Block-49';
            blockPost = '';
            stims = [31 32];
            chans = [8 7 48];
        case 'd5cd55'
            % sid = SIDS{2};
            tp = 'D:\Subjects\d5cd55\data\D8\d5cd55_BetaTriggeredStim';
            blockPre = 'Block-47';
            blockPost = 'Block-51';
            stims = [54 62];
            chans = [53 61 63];
        case 'c91479'
            % sid = SIDS{3};
            tp = 'D:\Subjects\c91479\data\d7\c91479_BetaTriggeredStim';
            blockPre = 'BetaPhase-9';
            blockPost = 'BetaPhase-15';
            stims = [55 56];
            chans = [64 63 48];
        case '7dbdec'
            % sid = SIDS{4};
            tp = 'D:\Subjects\7dbdec\data\d7\7dbdec_BetaTriggeredStim';
            blockPre = 'BetaPhase-16';
            blockPost = 'BetaPhase-18';
            stims = [11 12];
            chans = [4 5 14];
        case '9ab7ab'
            %             sid = SIDS{5};
            tp = 'D:\Subjects\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim';
            blockPre = 'BetaPhase-1';
            blockPost = 'BetaPhase-4';
            stims = [59 60];
            chans = [51 52 53 58 57];
            % chans = 29;
        case '702d24'
            tp = 'D:\Subjects\702d24\data\d7\702d24_BetaStim';
            blockPre = 'BetaPhase-3';
            blockPost = 'BetaPhase-5';
            stims = [13 14];
            chans = [4 5 21];
        case 'ecb43e' % added DJC 7-23-2015 NO GOOD TDT PRE POST, USE CLINICAL DATA
            tp = 'D:\Subjects\ecb43e\data\d7\BetaStim';
            blockPre = 'Block-49';
            blockPost = '';
            stims = [56 64];
            chans = [47 55];
        otherwise
            error('unknown SID entered');
    end
end

chans = [1:64];

%% openTank Pre
tank = TTank;
tank.openTank(tp);
tank.selectBlock(blockPre);

ecoTotPre = cell(1,64);

 for chan = chans
        
        %% load in ecog data for that channel
        fprintf('loading in ecog data:\n');
        tic;
        grp = floor((chan-1)/16);
        ev = sprintf('ECO%d', grp+1);
        achan = chan - grp*16;
        
        %         [eco, efs] = tdt_loadStream(tp, block, ev, achan);
        [eco, info] = tank.readWaveEvent(ev, achan);
        efs = info.SamplingRateHz;
        eco = eco';
        
        toc;
        
        ecoTotPre{chan} = eco;
 end
tank.closeTank;


%% openTank Post
tank = TTank;
tank.openTank(tp);
tank.selectBlock(blockPost);

ecoTotPost = cell(1,64);

 for chan = chans
        
        %% load in ecog data for that channel
        
        %% load in ecog data for that channel
        fprintf('loading in ecog data:\n');
        tic;
        grp = floor((chan-1)/16);
        ev = sprintf('ECO%d', grp+1);
        achan = chan - grp*16;
        
        %         [eco, efs] = tdt_loadStream(tp, block, ev, achan);
        [eco, info] = tank.readWaveEvent(ev, achan);
        efs = info.SamplingRateHz;
        eco = eco';
        
        toc;
        
        ecoTotPost{chan} = eco;
 end
 

tank.closeTank;

%% save it 

save(fullfile(META_DIR, [sid '_PreAndPostStimResting.mat']), 'efs', 'ecoTotPre', 'ecoTotPost', 'sid');
%% pre

tpre = [0:length(ecoTotPre{1})-1]/efs;

p = numSubplots(length(chans));


figure
hold on



for i = chans
    subplot(p(1),p(2),i);
    plot(tpre,ecoTotPre{i})
    title(sprintf('Chan %d',i))
    
end

xlabel('Time in seconds')
ylabel('Amplitude in uV')
subtitle(sprintf('Pre Raw Data for %s',sid))

SaveFig(OUTPUT_DIR, sprintf('PreStimRawTrace-%s', sid), 'png', '-r600');
%% post 

tpost = [0:length(ecoTotPost{1})-1]/efs;


figure
hold on

for i = chans
    subplot(p(1),p(2),i);
    plot(tpost,ecoTotPost{i})
    title(sprintf('Chan %d',i))
    
end

xlabel('Time in seconds')
ylabel('Amplitude in uV')
subtitle(sprintf('Post Raw Data for %s',sid))


SaveFig(OUTPUT_DIR, sprintf('PostStimRawTrace-%s', sid), 'png', '-r600');


%% convert the cell to a matrix

matrixSig = zeros(length(eco),length(chans));

for i = chans
    
    
    
end
