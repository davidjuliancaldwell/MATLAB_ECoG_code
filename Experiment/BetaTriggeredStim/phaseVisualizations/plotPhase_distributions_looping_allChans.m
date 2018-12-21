%% script to plot phase distributions of beta triggered stim signal
% takes in fit signals from all subjects, for all channels, and generates
% plots

% David.J.Caldwell 8.26.2018
%%
%close all;clear all;clc
%close all
baseDir = 'C:\Users\david\Data\Output\BetaTriggeredStim\PhaseDelivery\';
addpath(baseDir);

OUTPUT_DIR = 'C:\Users\david\Data\Output\BetaTriggeredStim\PhaseDelivery\allChans';
TouchDir(OUTPUT_DIR);

SIDS = {'d5cd55','c91479','7dbdec','9ab7ab','702d24','ecb43e','0b5a2e','0b5a2ePlayback'};
valueSet = {{'s',180,1,[54 62],[1 49 58 59],53},{'m',[0 180],2,[55 56],[2 3 31 57],64},{'s',180,3,[11 12],[57],4},...
    {'s',270,4,[59 60],[1 9 10 35 43],51},{'m',[90,270],5,[13 14],[23 27 28 29 30 32 44 52 60],5},...
    {'t',[270,90,12345],6,[56 64],[57:64],55},{'m',[90,270],7,[22 30],[17 18 19 24 25 28 29],31},{'m',[90,270],8,[22 30],[17 18 19 24 25 28 29],31}};
M = containers.Map(SIDS,valueSet,'UniformValues',false);

modifier = '_51samps_12_20_40ms_randomstart';
%modifier = '_13samps_8_30_40ms_randomstart';
%modifier = '_13samps_10_30_40ms_randomstart';

%modifierPhase = '_51samps_12_20_40m_0startPhase';


% settings
hilbPlot = 0;
acausalPlot = 0;
rawPlot = 1;
saveIt = 1;
threshold = 0.7; %r^2
% fThresholdMin = 10.01; % Hz2
% fThresholdMax = 29.99; % Hz
testStatistic = 'omnibus';
fThresholdMin = 12.01; % Hz
fThresholdMax = 19.99; % Hz
%fThresholdMin = 10.01; % Hz
%fThresholdMax = 29.99; % Hz

SIDS = {'0b5a2e'};

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for sid = SIDS
    sid = sid{:};
    load([sid '_phaseDelivery_allChans' modifier '.mat']);
    closeAll = 0;
    
    fprintf(['running for subject ' sid '\n']);
    
    if (strcmpi(sid,'0b5a2ePlayback'))
        sid = '0b5a2ePlayback';
    end
    
    info = M(sid);
    type = info{1};
    subjectNum = info{3};
    desiredF = info{2};
    stims = info{4};
    bads = info{5};
    betaChan = info{6};
    chans = [1:64];
    % chans = [14,21,23,31];
    %chans = 31;
    % chans = 23;
    badsTotal = [stims bads];
    chans(ismember(chans, badsTotal)) = [];
    % chans = 28
    
    %chans = betaChan;
    %chans = [39 40 47 48 63 64];
    chans = betaChan;
    
    chans = 14;
    
    if strcmp(type,'m') || strcmp(type,'t')
        if rawPlot
            for chan = chans
                fprintf(['chan ' num2str(chan) '\n'])
                signalType = 'raw';
                plotPhase_distributions_function(f_pos(:,chan),phase_at_0_pos(:,chan),r_square_pos(:,chan),threshold,desiredF(1),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt,testStatistic,fThresholdMin,fThresholdMax);
                plotPhase_distributions_function(f_neg(:,chan),phase_at_0_neg(:,chan),r_square_neg(:,chan),threshold,desiredF(2),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt,testStatistic,fThresholdMin,fThresholdMax)   ;
                plotPhase_subplots_func(t,fitline_pos(:,:,chan),f_pos(:,chan),phase_at_0_pos(:,chan),r_square_pos(:,chan),threshold,desiredF(1),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt,fThresholdMin,fThresholdMax)    ;
                plotPhase_subplots_func(t,fitline_neg(:,:,chan),f_neg(:,chan),phase_at_0_neg(:,chan),r_square_neg(:,chan),threshold,desiredF(2),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt,fThresholdMin,fThresholdMax);
            end
            
            if closeAll
                close all
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if acausalPlot
            for chan = chans
                fprintf(['chan ' num2str(chan) '\n'])
                signalType = 'filtered';
                plotPhase_distributions_function(f_pos_acaus(:,chan),phase_at_0_pos_acaus(:,chan),r_square_pos_acaus(:,chan),threshold,desiredF(1),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt,testStatistic,fThresholdMin,fThresholdMax)      ;
                plotPhase_distributions_function(f_neg_acaus,phase_at_0_neg_acaus(:,chan),r_square_neg_acaus(:,chan),desiredF(2),threshold,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt,testStatistic,fThresholdMin,fThresholdMax)     ;
                plotPhase_subplots_func(t,fitline_pos_acaus(:,:,chan),f_pos_acaus(:,chan),phase_at_0_pos_acaus(:,chan),r_square_pos_acaus(:,chan),threshold,desiredF(1),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt,fThresholdMin,fThresholdMax)    ;
                plotPhase_subplots_func(t,fitline_neg_acaus(:,:,chan),f_neg_acaus(:,chan),phase_at_0_neg_acaus(:,chan),r_square_neg_acaus(:,chan),threshold,desiredF(2),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt,fThresholdMin,fThresholdMax);
            end
            if closeAll
                close all
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmp(type,'s')|| strcmp(type,'t')
        if rawPlot
            
            
            for chan = chans
                fprintf(['chan ' num2str(chan) '\n'])
                signalType = 'raw';
                plotPhase_distributions_function(f(:,chan),phase_at_0(:,chan),r_square(:,chan),threshold,desiredF,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt,testStatistic,fThresholdMin,fThresholdMax);
                plotPhase_subplots_func(t,fitline(:,:,chan),f(:,chan),phase_at_0(:,chan),r_square(:,chan),threshold,desiredF,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt,fThresholdMin,fThresholdMax)   ;
            end
            if closeAll
                close all
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if acausalPlot
            signalType = 'filtered';
            for chan = chans
                fprintf(['chan ' num2str(chan) '\n'])
                plotPhase_distributions_function(f_acaus(:,chan),phase_at_0(:,chan),r_square(:,chan),threshold,desiredF,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt,testStatistic,fThresholdMin,fThresholdMax)     ;
                plotPhase_subplots_func(t,fitline_acaus(:,:,chan),f_acaus(:,chan),phase_at_0_acaus(:,chan),r_square_acaus(:,chan),threshold,desiredF,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt,fThresholdMin,fThresholdMax);
            end
            if closeAll
                close all
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end

% figure
% for i = 1:64
% subplot(8,8,i)
% histogram(f(r_square(:,i)>threshold & f>10,i))
% end


