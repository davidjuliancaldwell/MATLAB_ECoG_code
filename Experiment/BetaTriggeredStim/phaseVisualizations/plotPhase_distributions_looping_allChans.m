%% script to plot phase distributions of beta triggered stim signal
% takes in fit signals from all subjects, for all channels, and generates
% plots

% David.J.Caldwell 8.26.2018
%%
%close all;clear all;clc
baseDir = 'C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\BetaStimManuscript_4_30-2018\';
addpath(baseDir);

OUTPUT_DIR = 'C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\BetaStimManuscript_4_30-2018\allChans';
TouchDir(OUTPUT_DIR);

SIDS = {'d5cd55','c91479','7dbdec','9ab7ab','702d24','ecb43e','0b5a2e','0b5a2ePlayback'};
valueSet = {{'s',180,1,[54 62],[1 49 58 59],53},{'m',[0 180],2,[55 56],[2 3 31 57],64},{'s',180,3,[11 12],[57],4},...
    {'s',270,4,[59 60],[1 9 10 35 43],51},{'m',[90,270],5,[13 14],[23 27 28 29 30 32 44 52 60],5},...
    {'m',[90,180],6,[56 64],[57:64],55},{'m',[90,270],7,[22 30],[17 18 19 25 29],31},{'m',[90,270],8,[22 30],[17 18 19 25 29],31}};
M = containers.Map(SIDS,valueSet,'UniformValues',false);


SIDS = {'d5cd55'};

gcp;  %parallel pool
%
% settings
hilbPlot = 0;
acausalPlot = 1;
rawPlot = 1;
saveIt = 0;
closeAll = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for sid = SIDS
    sid = sid{:};
    load([sid '_phaseDelivery_allChans.mat']);
    
    fprintf(['running for subject ' sid '\n']);
    info = M(sid);
    type = info{1};
    subjectNum = info{3};
    desiredF = info{2};
    stims = info{4};
    bads = info{5};
    betaChan = info{6};
    chans = [1:64];
    badsTotal = [stims bads];
    chans(ismember(chans, badsTotal)) = [];
    
    if strcmp(type,'m')
          if rawPlot
            for chan = chans
                fprintf(['chan ' num2str(chan) '\n'])
                signalType = 'raw';
                plotPhase_distributions_function(f_pos(:,chan),phase_at_0_pos(:,chan),r_square_pos(:,chan),desiredF(1),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt);
                plotPhase_distributions_function(f_neg(:,chan),phase_at_0_neg(:,chan),r_square_neg(:,chan),desiredF(2),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)   ;
                plotPhase_subplots_func(t,fitline_pos(:,:,chan),f_pos(:,chan),phase_at_0_pos(:,chan),r_square_pos(:,chan),desiredF(1),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)    ;    
                plotPhase_subplots_func(t,fitline_neg(:,:,chan),f_neg(:,chan),phase_at_0_neg(:,chan),r_square_neg(:,chan),desiredF(2),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt);
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
                plotPhase_distributions_function(f_pos_acaus(:,chan),phase_at_0_pos,r_square_pos,desiredF(1),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)      ;
                plotPhase_distributions_function(f_neg_acaus,phase_at_0_neg,r_square_neg,desiredF(2),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)     ; 
                plotPhase_subplots_func(t,fitline_pos_acaus(:,:,chan),f_pos_acaus,phase_at_0_pos,r_square_pos,desiredF(1),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)    ;           
                plotPhase_subplots_func(t,fitline_neg_acaus(:,:,chan),f_neg_acaus,phase_at_0_neg,r_square_neg,desiredF(2),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt);
            end
            if closeAll
                close all
            end    
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif strcmp(type,'s')
        if rawPlot
            

            for chan = chans
                fprintf(['chan ' num2str(chan) '\n'])  
                signalType = 'raw';         
                plotPhase_distributions_function(f(:,chan),phase_at_0(:,chan),r_square(:,chan),desiredF,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt);
                plotPhase_subplots_func(t,fitline(:,:,chan),f(:,chan),phase_at_0(:,chan),r_square(:,chan),desiredF,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)   ;       
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
                plotPhase_distributions_function(f_acaus(:,chan),phase_at_0(:,chan),r_square(:,chan),desiredF,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)     ;         
                plotPhase_subplots_func(t,fitline_acaus(:,:,chan),f,phase_at_0,r_square,desiredF,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt);
            end
            if closeAll
                close all
            end          
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
    end      
end


