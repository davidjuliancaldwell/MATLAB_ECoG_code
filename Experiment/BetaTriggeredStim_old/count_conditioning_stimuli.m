%% script to plot phase distributions of beta triggered stim signal
% takes in fit signals from all subjects, for all channels, and generates
% plots

% David.J.Caldwell 8.26.2018
%%
%close all;clear all;clc
baseDir = 'C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\PhaseDelivery\';
addpath(baseDir);

OUTPUT_DIR = 'C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\PhaseDelivery\allChans';
TouchDir(OUTPUT_DIR);

SIDS = {'d5cd55','c91479','7dbdec','9ab7ab','702d24','ecb43e','0b5a2e','0b5a2ePlayback'};
valueSet = {{'s',180,1,[54 62],[1 49 58 59],53},{'m',[0 180],2,[55 56],[2 3 31 57],64},{'s',180,3,[11 12],[57],4},...
    {'s',270,4,[59 60],[1 9 10 35 43],51},{'m',[90,270],5,[13 14],[23 27 28 29 30 32 44 52 60],5},...
    {'t',[270,90,12345,12345],6,[56 64],[57:64],55},{'m',[90,270],7,[22 30],[17 18 19 24 25 28 29],31},{'m',[90,270],8,[22 30],[17 18 19 24 25 28 29],31}};
M = containers.Map(SIDS,valueSet,'UniformValues',false);
modifierEP = '-reref';

modifierPhase = '_51samps_12_20_40ms_randomstart';



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

countVec = [];
subjectNumVec = [];
fVec = [];
for sid = SIDS
    sid = sid{:};
    
    load(strcat(subjid,['epSTATS-PP-sig' modifierEP '.mat']))
    load([sid '_phaseDelivery_allChans' modifierPhase '.mat']);
    closeAll = 0;
    
    fprintf(['running for subject ' sid '\n']);
    
    if (strcmpi(sid,'0b5a2ePlayback'))
        sid = '0b5a2ePlayback';
    end
    
    info = M(sid);
    type = info{1};
    subjectNum = info{3};
    desiredF = info{2};
    
    
    % figure out number of test conditions
    numTypes = length(dataForPPanalysis{betaChan});
    
    if strcmp(sid,'0b5a2e') || strcmp(sid,'0b5a2ePlayback') || strcmp(sid,'ecb43e')
        nullType = 3;
    else
        nullType = NaN;
    end
    
    if strcmp(type,'m')
        indices = [1,2];
    elseif strcmp(type,'s')
        indices = 1;
    elseif strcmp(type,'t')
        indices = [1,2,4];
    end
    
    numVec = [];
    
    for index = indices
        
        if (strcmp(type,'m') || strcmp(type,'t')) && (index == 1)
            num = size(f_pos,1);
        elseif (strcmp(type,'m') || strcmp(type,'t')) && (index == 2)
            num = size(f_neg,1);
        elseif (strcmp(type,'s') && index ==1) || (strcmp(type,'t') && index == 4)
            num = size(f,1);
        end
        numVec(index) = num;
    end
    
    countVec = [countVec numVec];
    subjectNumVec = [subjectNumVec; repmat(subjectNum,length(numVec),1)];
    fVec = [fVec desiredF];
    
    
end

%%
tableCount = table(countVec',categorical(subjectNumVec),categorical(fVec'),...
    'VariableNames',{'countCond','subjectNum','desiredF'});
% group stats
