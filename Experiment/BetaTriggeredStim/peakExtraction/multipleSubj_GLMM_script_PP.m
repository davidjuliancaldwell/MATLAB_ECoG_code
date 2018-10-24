%% Multisubject analysis with general linear mixed model
% peak to peak values used
%
% David.J.Caldwell 9.19.2018

%close all;clear all;clc
clear all
Z_Constants;
SUB_DIR = fullfile(myGetenv('subject_dir'));
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'));

%% parameters


SIDS = {'d5cd55','c91479','7dbdec','9ab7ab','702d24','ecb43e','0b5a2e','0b5a2ePlayback'};

valueSet = {{'s',180,1,[54 62],[1 49 58 59],[44 45 46 47 48 52 53 55 60 61 63],53,2.5},...
    {'m',[0 180],2,[55 56],[1 2 3 31 57],[39 40 47 48 63 64],64,3},...
    {'s',180,3,[11 12],[57],[4 5 10 13 18 19 20],4,3.5},...
    {'s',270,4,[59 60],[1 9 10 35 43],[41 42 43 44 45 49 50 51 52 53 57 58 61 62],51,0.75},...
    {'m',[90,270],5,[13 14],[23 27 28 29 30 32 44 52 60],[5],5,0.75},...
    {'t',[270,90,12345,12345],6,[56 64],[57:64],[46 48 54 55 63],55,1.75}...
    {'m',[90,270],7,[22 30],[24 25 29],[13 14 15 16 20 21 23 31 32 39 40],31,1.75},...
    {'m',[90,270],8,[22 30],[24 25 29],[13 14 15 16 20 21 23 31 32 39 40],31,1.75}};
M = containers.Map(SIDS,valueSet,'UniformValues',false);
modifierEP = '-reref';
SIDS = {'d5cd55','c91479','7dbdec','9ab7ab','702d24','ecb43e','0b5a2e'};

modifierPhase = '_13samps_8_30_40ms_randomstart';

% decide how to plot circles - std deviation or vector length
markerToUse = 'vecLength';
testStatistic = 'omnibus';

threshold = 0.7;
%fThresholdMin = 12.01;
%fThresholdMax = 19.99;

fThresholdMin = 10;
fThresholdMax = 29.99;

markerMin = 50;
markerMax = 200;
minData = 0;
maxData = 1;

%%

betaMags5 = [];
betaMags3 = [];
betaMags1 = [];
betaBase = [];
betaSID = {};
numStims = {};
totalMags = [];
chanLabels = [];
anovaType = {};
stimLevelCombined =[];
phaseDelivery = [];
phaseDeliveryBinned = [];
%answer = input('use zscore or raw values? Enter "zscore" or "raw"  \n','s');

% exclude playback for now
% which
subdir = 'PeaktoPeakEP';

for sid = SIDS
    
    sid = sid{:};
    subjid = sid;
    info = M(sid);
    type = info{1};
    subjectNum = info{3};
    desiredF = info{2};
    stims = info{4};
    bads = info{5};
    goodEPs = info{6};
    betaChan = info{7};
    stimLevel = info{8};
    chans = [1:64];
    badsTotal = [stims bads];
    chans(ismember(chans, badsTotal) | ~ismember(chans,goodEPs)) = [];
    
    load(strcat(subjid,['epSTATS-PP-sig' modifierEP '.mat']))
    load([sid '_phaseDelivery_allChans' modifierPhase '.mat']);
    
    % here's where I pick those channels!
    %  chan = betaChan;
    %   chans = betaChan;
    
    % figure out number of test conditions
    numTypes = length(dataForPPanalysis{betaChan});
    
    if strcmp(sid,'0b5a2e') || strcmp(sid,'0b5a2ePlayback') || strcmp(sid,'ecb43e')
        nullType = 3;
    else
        nullType = NaN;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % bring in phase
    
    %  h = [];
    peakPhaseVec = [];
    chanVec = [];
    peakPhaseRep = [];
    indexVec = [];
    
    load(strcat(subjid,['epSTATS-PP-sig' modifierEP '.mat']))
    load([sid '_phaseDelivery_allChans' modifierPhase '.mat']);
    
    fprintf(['running for subject ' sid '\n']);
    
    %%
    
    if strcmp(type,'m')
        indices = [1,2];
    elseif strcmp(type,'s')
        indices = 1;
    elseif strcmp(type,'t')
        indices = [1,2,4];
    end
    
    for index = indices
        
        if (strcmp(type,'m') || strcmp(type,'t')) && (index == 1)
            [peakPhase,peakStd,peakLength,circularTest,markerSize] =  phase_delivery_accuracy_forPP(r_square_pos,...
                threshold,phase_at_0_pos,chans,desiredF(index),markerMin,markerMax,minData,maxData,markerToUse,testStatistic,f_pos,fThresholdMin,fThresholdMax);
        elseif (strcmp(type,'m') || strcmp(type,'t')) && (index == 2)
            [peakPhase,peakStd,peakLength,circularTest,markerSize] =  phase_delivery_accuracy_forPP(r_square_neg,...
                threshold,phase_at_0_neg,chans,desiredF(2),markerMin,markerMax,minData,maxData,markerToUse,testStatistic,f_neg,fThresholdMin,fThresholdMax);
        elseif (strcmp(type,'s') && index ==1) || (strcmp(type,'t') && index == 3)
            [peakPhase,peakStd,peakLength,circularTest,markerSize] =  phase_delivery_accuracy_forPP(r_square,...
                threshold,phase_at_0,chans,desiredF,markerMin,markerMax,minData,maxData,markerToUse,testStatistic,f,fThresholdMin,fThresholdMax);
        end       
        peakPhaseVec(index,:) = peakPhase;   
    end
    
    for chan = chans
        % for each channel, a single stacked vector of all of the responses for a given number of stimuli
        tB = [];
        t1 = [];
        t2 = [];
        t3 = [];
        tN = [];
        lengthItems = 0;
        
        %%%%%%%%%%%%%%%%%%%%% screen
        tempMagScreen = 1e6*dataForPPanalysis{chan}{1}{1};
        tempLabelScreen = dataForPPanalysis{chan}{1}{4};
        tempKeepsScreen = dataForPPanalysis{chan}{1}{5};
        
        if nanmean(tempMagScreen(tempLabelScreen ==0 & tempKeepsScreen)) > 150
            
            for i = 1:numTypes
                
                if i ~= nullType
                    tempMag = 1e6*dataForPPanalysis{chan}{i}{1};
                    tempLabel = dataForPPanalysis{chan}{i}{4};
                    tempKeeps = dataForPPanalysis{chan}{i}{5};
                    
                    tempBase = tempMag(tempLabel==0 & tempKeeps);
                    tempResp1 = tempMag(tempLabel==1 & tempKeeps);
                    tempResp2 = tempMag(tempLabel==2 & tempKeeps);
                    tempResp3 = tempMag(tempLabel==3 & tempKeeps);
                    
                    if i == 1
                        tB = tempBase;
                        tB = [tB tempBase];
                    end
                    t1 = [t1 tempResp1];
                    t2 = [t2 tempResp2];
                    t3 = [t3 tempResp3];
                    
                    if i == 1
                        lengthType = length(tempBase)+length(tempResp1)+length(tempResp2)+length(tempResp3);
                    else
                        lengthType = length(tempResp1)+length(tempResp2)+length(tempResp3);
                    end
                    
                    lengthItems = lengthItems +lengthType;
                    vecType = repmat(desiredF(i),lengthType,1);
                    vecTypeC = string(vecType)';
                    anovaType = [anovaType{:} vecTypeC];
                    
                    phaseVecChosen = peakPhaseVec(i,goodEPs==chan);
                    phaseVec = repmat(phaseVecChosen,lengthType,1)';
                    phaseDelivery = [phaseDelivery phaseVec];
                    
                    phaseBinned = phaseVec;
                    if any(phaseBinned > 180)
                        phaseBinned(:) = 270;
                    else
                    phaseBinned(:) = 90;
                    end
                    phaseDeliveryBinned = [phaseDeliveryBinned phaseBinned];
                    
                    if i ==1
                        typeResp = [tempResp3 tempResp2 tempResp1 tempBase];
                        totalMags = [totalMags typeResp];
                        num5S = repmat('Ct>=5',length(tempResp3),1);
                        num3S= repmat('3<=Ct<=4',length(tempResp2),1);
                        num1S = repmat('1<=Ct<=2',length(tempResp1),1);
                        numBaseS = repmat('Base',length(tempBase),1);
                        
                        b5C = cellstr(num5S)';
                        b3C = cellstr(num3S)';
                        b1C = cellstr(num1S)';
                        BC = cellstr(numBaseS)';
                        numStims = [numStims{:} b5C b3C b1C BC];
                    else
                        typeResp = [tempResp3 tempResp2 tempResp1];
                        totalMags = [totalMags typeResp];
                        num5S = repmat('Ct>=5',length(tempResp3),1);
                        num3S= repmat('3<=Ct<=4',length(tempResp2),1);
                        num1S = repmat('1<=Ct<=2',length(tempResp1),1);
                        
                        b5C = cellstr(num5S)';
                        b3C = cellstr(num3S)';
                        b1C = cellstr(num1S)';
                        numStims = [numStims{:} b5C b3C b1C];
                    end
                end
            end
            lengthToRep = lengthItems;
            sidString = repmat(sid,lengthToRep,1);
            sidCell = cellstr(sidString)';
            chanLabels = [chanLabels repmat(chan,lengthToRep,1)'];
            betaMags5 = [betaMags5 t3];
            betaMags3 = [betaMags3 t2];
            betaMags1 = [betaMags1 t1];
            betaBase = [betaBase tB] ;
            betaSID = [betaSID{:} sidCell];
            stimLevelCombined = [stimLevelCombined repmat(stimLevel,lengthToRep,1)'];
        end
    end
end


%%
tableBetaStim = table(totalMags',stimLevelCombined',categorical(numStims)',categorical(betaSID)',categorical(chanLabels)',categorical(phaseDeliveryBinned'),...
    'VariableNames',{'Magnitude','stimLevel','NumStims','SID','channel','phaseClass'});
% group stats

statarray = grpstats(tableBetaStim,{'SID','NumStims','channel','phaseClass'},{'mean','sem'},...
    'DataVars','Magnitude');

grpstats(totalMags',numStims',0.05)

%%
numSubj = 7;
numDims = 4;
j = 1;

newOrder = [3 1 2 4];
newOrder = repmat(newOrder,1,numSubj);
subjMult = repmat([0:4:24],numDims,1);
subjMult = subjMult(:);
newOrder = newOrder+subjMult';
statarray = statarray(newOrder,:);
%%
newSidOrder = [6 5 3 4 2 7 1];
newSidOrder = repmat(newSidOrder,numDims,1);
newSidOrder = newSidOrder(:);
subjNumStim = repmat([1:4],1,numSubj);

newSidOrder = 4*newSidOrder + subjNumStim' - 4;
statarray = statarray(newSidOrder,:);

%%
[groupings,meansChannelSID] = findgroups(tableBetaStim(:,{'NumStims','SID','channel','phaseClass'}));

meansChannelSID.mean = splitapply(@nanmean,tableBetaStim.Magnitude,groupings);
%%
count = 1;
for name = unique(meansChannelSID.SID)'
    for chan = unique(meansChannelSID.channel(meansChannelSID.SID == name))'
        for numStimTrial = unique(meansChannelSID.NumStims)'
            for typePhase = unique(meansChannelSID.phaseClass)'
            base = meansChannelSID.mean(meansChannelSID.SID == name & meansChannelSID.channel == chan & meansChannelSID.NumStims == 'Base');
            percentDiff = 100*((meansChannelSID.mean(meansChannelSID.SID == name & meansChannelSID.channel == chan & meansChannelSID.NumStims == numStimTrial & meansChannelSID.phaseClass == typePhase) - base)/base);
            meansChannelSID.percentDiff(meansChannelSID.SID == name & meansChannelSID.channel == chan & meansChannelSID.NumStims == numStimTrial & meansChannelSID.phaseClass == typePhase) = percentDiff;
            end
        end
    end
end

figure
grpstats(meansChannelSID,{'NumStims','phaseClass'},{'mean','sem'},...
    'DataVars','percentDiff')%hierarchicalBoxplot(anovaTotalMags,{categorical(anovaNumStims),categorical(anovaBetaSID)})

return
%%
figure
prettybar(a1, label(keeps), colors, gcf);
set(gca, 'xtick', []);
ylabel('EP_N Magnitude(uV)');
title(sprintf('EP_N Magnitude by N_{CT}: One-Way Kruskal-Wallis F=%4.2f p=%0.4f', tableNull{2,5}, tableNull{2,6}));
%                                     figure
%%
% fit glme
glme = fitglme(tableBetaStim,'Magnitude~NumStims+stimLevel+phaseClass+(1|SID)+(-1 + NumStims | SID) + (-1 + stimLevel | SID) + (-1 + phaseClass | SID)',...
    'Distribution','Normal','Link','Identity','FitMethod','Laplace','DummyVarCoding','effects','EBMethod','Default')
%%
disp(glme)
anova(glme)
[psi,dispersion,stats] = covarianceParameters(glme)
psi
dispersion
stats
%%
% test effect between different stim levels

% between 3<CT<4 and Base
H = [0,0,0,1,-1,0];

[pVal,F,DF1,DF2] = coefTest(glme,H);
fprintf(['p value between 3<ct<4 and base = ' num2str(pVal) '\n']);

% between 1<ct<2 and Base

H = [0,0,1,0,1,0];

[pVal,F,DF1,DF2] = coefTest(glme,H);
fprintf(['p value between 1<ct<2 and base = ' num2str(pVal) '\n']);

% between >5 and base
H = [0,0,1,1,2,0];

[pVal,F,DF1,DF2] = coefTest(glme,H);
fprintf(['p value between >5 and base = ' num2str(pVal) '\n']);

% between 1<ct<2 and >5

H = [0,0,2,1,1,0];

[pVal,F,DF1,DF2] = coefTest(glme,H);
fprintf(['p value between 1<ct<2 and >5 = ' num2str(pVal) '\n']);

% between 3<CT<4 and > 5

H = [0,0,1,2,1,0];

[pVal,F,DF1,DF2] = coefTest(glme,H);
fprintf(['p value between 3<ct<4 and > 5 ' num2str(pVal) '\n']);

% between PHASE

H = [0,0,0,0,0,-1];

[pVal,F,DF1,DF2] = coefTest(glme,H);
fprintf(['p value between phases ' num2str(pVal) '\n']);

%%
[pVal,F,DF1,DF2] = coefTest(glme)

%% MULTIPLE SUBJECTS - plot
%
% D5cd55 - subject 1
% C91479 - subject 2
% 7dbdec - subject 3
% 9ab7ab - subject 4
% 702d24 - subject 5
% Ecb43e - subject 6
% 0b5a2e - subject 7

figure

sem = table2array(statarray(:,{'sem_Magnitude'}));
means = table2array(statarray(:,{'mean_Magnitude'}));

load('line_red.mat');
colors = flipud(cm(round(linspace(1, size(cm, 1), numDims)), :));


k = 25;


% generate error bars

for i = 1:height(statarray)
    
    if j == 5
        j = 1;
    end
    
    h = errorbar(i,means(i),sem(i),'o','linew',3,'color',colors(j,:),'capsize',10);
    ylim([0 800])
    
    set(h, 'MarkerSize', 5, 'MarkerFaceColor', colors(j,:), ...
        'MarkerEdgeColor', colors(j,:));
    hold on
    
    ax = gca;
    
    if j ==2
        text(i+0.15,min(means(:,1))-6,sprintf([num2str(floor(i/4)+1)]),'fontsize',14)
        
    end
    
    if mod(i,4) == 0 & i < 25
        line = vline(i+0.5);
        line.Color = [0.5 0.5 0.5];
    end
    ax.FontSize = 12;
    j = j+1;
end
ylabel('CCEP Magnitude (\muV)','fontsize',14,'fontweight','bold')
xlabel('Subject subdivided by number of conditioning pulses','fontsize',14,'fontweight','bold')

% set(gca,'XtickLabel',{'','>5','3->4', '1->2','Baseline'},'fontsize',14,'fontweight','bold')
ax.XTickLabelMode = 'manual';
ax.XTick = [];
title({'CCEP Magnitude across Subjects';},'fontsize',16,'fontweight','bold')



[h,icons,plots,legend_text] = legend({'Baseline','1-2','3-4','>5'},'fontsize',12);


%%
% figure
% plotResiduals(glme,'histogram','ResidualType','Pearson')
% figure
% plotResiduals(glme,'fitted','ResidualType','Pearson')
% figure
% plotResiduals(glme,'lagged','ResidualType','Pearson')
%
% %%
%
% tableBetaStim = table(anovaTotalMags',anovaStimLevel',categorical(anovaType)',categorical(anovaNumStims)',categorical(anovaBetaSID)',...
%     'VariableNames',{'Magnitude','stimLevel','Type','NumStims','SID'});
% glme = fitglme(tableBetaStim,'Magnitude~NumStims+Type+stimLevel+(1|SID)+(Type|SID)',...
%     'Distribution','Normal','Link','Identity','FitMethod','Laplace','DummyVarCoding','effects')
% disp(glme)
% anova(glme)
% [psi,dispersion,stats] = covarianceParameters(glme)
% psi
% dispersion
% stats
%
% %%
%
% H = [0,0,1,-1,0,0,0,0,0];
%
% [pVal,F,DF1,DF2] = coefTest(glme,H)
%
% H = [0,0,0,1,-1,0,0,0,0];
%
% [pVal,F,DF1,DF2] = coefTest(glme,H)
%
%
% H = [0,0,0,1,0,-1,0,0,0];
%
% [pVal,F,DF1,DF2] = coefTest(glme,H)
%
%
% H = [0,0,1,0,0,-1,0,0,0];
%
% [pVal,F,DF1,DF2] = coefTest(glme,H)