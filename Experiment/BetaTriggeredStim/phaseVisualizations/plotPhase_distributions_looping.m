%% 5-3-2018 - script to plot phase distributions of beta triggered stim signal

%%
close all;clear all;clc
baseDir = 'C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\BetaStimManuscript_4_30-2018\';
addpath(baseDir);

OUTPUT_DIR = 'C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\BetaStimManuscript_4_30-2018\allChans';
TouchDir(OUTPUT_DIR);

SIDS = {'d5cd55','c91479','7dbdec','9ab7ab','702d24','ecb43e','0b5a2e','0b5a2ePlayback'};
valueSet = {{'s',180,1},{'m',[0 180],2},{'s',180,3},{'s',270,4},{'m',[90,270],5},{'m',[90,180],6},{'m',[90,270],7},{'m',[90,270],8}};
M = containers.Map(SIDS,valueSet,'UniformValues',false);

%gcp; % parallel pool

files = dir('*.mat');

% settings
hilbPlot = 0;
acausalPlot = 1;
rawPlot = 1;
saveIt = 1;
closeAll = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for file = files'
    load(file.name);
    subStrings = split(file.name,'_');
    sid = subStrings{1};
    chan = str2num(subStrings{2});
    
    info = M(sid);
    type = info{1};
    subjectNum = info{3};
    desiredF = info{2};
    
    
    if strcmp(type,'m')
        
        if rawPlot
            
            signalType = 'raw';
            plotPhase_distributions_function(f_pos,phase_at_0_pos,r_square_pos,desiredF(1),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)
            
            plotPhase_distributions_function(f_neg,phase_at_0_neg,r_square_neg,desiredF(2),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)
            
            plotPhase_subplots_func(t,fitline_pos,f_pos,phase_at_0_pos,r_square_pos,desiredF(1),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)
            
            plotPhase_subplots_func(t,fitline_neg,f_neg,phase_at_0_neg,r_square_neg,desiredF(2),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)
            
            if closeAll
                close all
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if acausalPlot
            
            signalType = 'filtered';
            plotPhase_distributions_function(f_pos_acaus,phase_at_0_pos,r_square_pos,desiredF(1),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)
            
            plotPhase_distributions_function(f_neg_acaus,phase_at_0_neg,r_square_neg,desiredF(2),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)
            
            
            plotPhase_subplots_func(t,fitline_pos_acaus,f_pos_acaus,phase_at_0_pos,r_square_pos,desiredF(1),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)
            
            plotPhase_subplots_func(t,fitline_neg_acaus,f_neg_acaus,phase_at_0_neg,r_square_neg,desiredF(2),sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)
            
            if closeAll
                close all
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if hilbPlot
            
            plotPhase_distributions_function_hilb(hilbPhasePos0,desiredF(1),sid,subjectNum,chan,type,OUTPUT_DIR,saveIt)
            
            plotPhase_distributions_function_hilb(hilbPhaseNeg0,desiredF(2),sid,subjectNum,chan,type,OUTPUT_DIR,saveIt)
            
            
            if closeAll
                close all
            end
            
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    elseif strcmp(type,'s')
        
        if rawPlot
                        signalType = 'raw';

            plotPhase_distributions_function(f,phase_at_0,r_square,desiredF,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)
            plotPhase_subplots_func(t,fitline,f,phase_at_0,r_square,desiredF,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)
            
            if closeAll
                close all
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        if acausalPlot
                        signalType = 'filtered';

            plotPhase_distributions_function(f_acaus,phase_at_0,r_square,desiredF,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)
            
            plotPhase_subplots_func(t,fitline_acaus,f,phase_at_0,r_square,desiredF,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)
            
            if closeAll
                close all
            end
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if hilbPlot
            
            plotPhase_distributions_function_hilb(hilbPhase0,desiredF,sid,subjectNum,chan,type,OUTPUT_DIR,saveIt)
            
            if closeAll
                close all
            end
        end
        
    end
    
    
end


