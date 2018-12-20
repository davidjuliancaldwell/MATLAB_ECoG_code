%% Multisubject analysis with general linear mixed model
% peak to peak values used
%
% David.J.Caldwell 9.19.2018

close all;clear all;clc
%clear all
Z_Constants;
SUB_DIR = fullfile(myGetenv('subject_dir'));
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'));

%% parameters


SIDS = {'d5cd55','c91479','7dbdec','9ab7ab','702d24','ecb43e','0b5a2e','0b5a2ePlayback'};

% valueSet = {{'s',180,1,[54 62],[1 49 58 59],[44 45 46 47 48 52 53 55 60 61 63],53,2.5},...
%     {'m',[0 180],2,[55 56],[1 2 3 31 57],[39 40 47 48 63 64],64,3},...
%     {'s',180,3,[11 12],[57],[4 5 10 13 18 19 20],4,3.5},...
%     {'s',270,4,[59 60],[1 9 10 35 43],[41 42 43 44 45 49 50 51 52 53 57 58 61 62],51,0.75},...
%     {'m',[90,270],5,[13 14],[23 27 28 29 30 32 44 52 60],[5],5,0.75},...
%     {'t',[270,90,12345,12345],6,[56 64],[57:63],[46 48 54 55 63],55,1.75}...
%     {'m',[90,270],7,[22 30],[24 25 29],[13 14 15 16 20 21 23 31 32 39 40],31,1.75},...
%     {'m',[90,270],8,[22 30],[24 25 29],[13 14 15 16 20 21 23 31 32 39 40],31,1.75}};


valueSet = {{'s',180,1,[54 62],[1 49 58 59],[44 45 46 52 53 55 60 61 63],53,2.5},...
    {'m',[0 180],2,[55 56],[1 2 3 31 57],[47 48 64],64,3},...
    {'s',180,3,[11 12],[57],[4 5 10 13],4,3.5},...
    {'s',270,4,[59 60],[1 9 10 35 43],[50 51 52 53 58],51,0.75},...
    {'m',[90,270],5,[13 14],[23 27 28 29 30 32 44 52 60],[5],5,0.75},...
    {'t',[270,90,12345,12345],6,[56 64],[57:63],[47 48 54 55 63],55,1.75}...
    {'m',[90,270],7,[22 30],[24 25 29],[14 15 16 20 21 23 31 32 40],31,1.75},...
    {'m',[90,270],8,[22 30],[24 25 29],[14 15 16 20 21 23 31 32 40],31,1.75}};

M = containers.Map(SIDS,valueSet,'UniformValues',false);
modifierEP = '-reref-50';

%modifierPhase = '_13samps_10_30_40ms_randomstart';
modifierPhase = '_51samps_12_20_40ms_randomstart';
% decide how to plot circles - std deviation or vector length
markerToUse = 'vecLength';
testStatistic = 'omnibus';

threshold = 0.7;
fThresholdMin = 12.01;
fThresholdMax = 19.99;

%fThresholdMin = 10;
%fThresholdMax = 29.99;
epThresholdMag = 150;

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
subjectNumVec = [];
numStims = {};
totalMags = [];
chanLabels = [];
betaLabels = [];
anovaType = {};
stimLevelCombined =[];
phaseDelivery = [];
phaseDeliveryBinned = [];
%answer = input('use zscore or raw values? Enter "zscore" or "raw"  \n','s');

% exclude playback for now
% which
subdir = 'PeaktoPeakEP';
%%
for sid = SIDS(1:end)
    
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
    
    if strcmp(sid,'0b5a2e') || strcmpi(sid,'0b5a2eplayback') || strcmp(sid,'ecb43e')
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
    
    %     load(strcat(subjid,['epSTATS-PP-sig' modifierEP '.mat']))
    %     load([sid '_phaseDelivery_allChans' modifierPhase '.mat']);
    %
    fprintf(['running for subject ' sid '\n']);
    
    %%
    if strcmp(type,'m')
        indices = [1,2];
    elseif strcmp(type,'s')
        indices = 1;
    elseif strcmp(type,'t')
        indices = [1,2,4];
    end
    
    peakPhaseVec = [];
    for index = indices
        
        if (strcmp(type,'m') || strcmp(type,'t')) && (index == 1)
            [peakPhase,peakStd,peakLength,circularTest,markerSize] =  phase_delivery_accuracy_forPP(r_square_pos,...
                threshold,phase_at_0_pos,chans,desiredF(index),markerMin,markerMax,minData,maxData,markerToUse,testStatistic,f_pos,fThresholdMin,fThresholdMax);
        elseif (strcmp(type,'m') || strcmp(type,'t')) && (index == 2)
            [peakPhase,peakStd,peakLength,circularTest,markerSize] =  phase_delivery_accuracy_forPP(r_square_neg,...
                threshold,phase_at_0_neg,chans,desiredF(2),markerMin,markerMax,minData,maxData,markerToUse,testStatistic,f_neg,fThresholdMin,fThresholdMax);
        elseif (strcmp(type,'s') && index ==1) || (strcmp(type,'t') && index == 4)
            [peakPhase,peakStd,peakLength,circularTest,markerSize] =  phase_delivery_accuracy_forPP(r_square,...
                threshold,phase_at_0,chans,desiredF,markerMin,markerMax,minData,maxData,markerToUse,testStatistic,f,fThresholdMin,fThresholdMax);
        end
        peakPhaseVec(index,:) = peakPhase;
    end
    
    for chan = chans
        % for each channel, a single stacked vector of all of the responses for a given number of stimuli
        lengthItems = 0;
        
        %%%%%%%%%%%%%%%%%%%%% screen
        tempMagScreen = 1e6*dataForPPanalysis{chan}{1}{1};
        tempLabelScreen = dataForPPanalysis{chan}{1}{4};
        tempKeepsScreen = dataForPPanalysis{chan}{1}{5};
        
        %%%%%%%%%%%%%%%%%%%%%%
        % want to code channel as unique to each subject
        
        if nanmean(tempMagScreen(tempLabelScreen ==0 & tempKeepsScreen)) > epThresholdMag
            if chan == betaChan
                beta = 1;
            else
                beta = 0;
            end
            
            for ii = 1:numTypes
                if ii ~= nullType
                    tempMag = 1e6*dataForPPanalysis{chan}{ii}{1};
                    tempLabel = dataForPPanalysis{chan}{ii}{4};
                    tempKeeps = dataForPPanalysis{chan}{ii}{5};
                    
                    tempBase = tempMag(tempLabel==0 & tempKeeps);
                    tempTest = tempMag(tempLabel~=0 & tempKeeps);
                    uniqueLabel = unique(tempLabel);
                    
                    if ii == 1
                        lengthType = length(tempBase)+length(tempTest);
                    else
                        lengthType = length(tempTest);
                    end
                    
                    lengthItems = lengthItems +lengthType;
                    vecType = repmat(desiredF(ii),lengthType,1);
                    vecTypeC = string(vecType)';
                    anovaType = [anovaType{:} vecTypeC];
                    
                    phaseVecChosen = peakPhaseVec(ii,goodEPs==chan);
                    phaseVec = repmat(phaseVecChosen,lengthType,1)';
                    phaseDelivery = [phaseDelivery phaseVec];
                    
                    phaseBinned = phaseVec;
                    if any(phaseBinned > 180)
                        phaseBinned(:) = 270;
                    else
                        phaseBinned(:) = 90;
                    end
                    phaseDeliveryBinned = [phaseDeliveryBinned phaseBinned];
                    
                    if ii ==1
                        numTest = [];
                        tempTestOrdered = [];
                        typeResp = [];
                        
                        for iii = 2:length(unique(tempLabel))
                            numTestTemp = repmat(['Test ' num2str(iii - 1)],sum(tempLabel(tempKeeps) == uniqueLabel(iii)),1);
                            numTest = [numTest; numTestTemp];
                            tempTestOrdered = [tempTestOrdered tempMag(tempLabel == uniqueLabel(iii) & tempKeeps)];
                        end
                        typeResp = [  tempBase tempTestOrdered];
                        totalMags = [totalMags typeResp];
                        
                        numBaseS = repmat('Base',length(tempBase),1);
                        bTest = cellstr(numTest)';
                        bC = cellstr(numBaseS)';
                        numStims = [numStims{:}  bC bTest  ];
                        
                    else
                        numTest = [];
                        tempTestOrdered = [];
                        typeResp = [];
                        
                        for iii = 2:length(unique(tempLabel))
                            numTestTemp = repmat(['Test ' num2str(iii - 1)],sum(tempLabel(tempKeeps) == uniqueLabel(iii)),1);
                            numTest = [numTest; numTestTemp];
                            tempTestOrdered = [tempTestOrdered tempMag(tempLabel == uniqueLabel(iii) & tempKeeps)];
                            
                        end
                        
                        typeResp = [tempTestOrdered];
                        totalMags = [totalMags typeResp];
                        
                        bTest = cellstr(numTest)';
                        numStims = [numStims{:} bTest];
                    end
                    
                elseif ii == nullType
                    
                    tempMag = 1e6*dataForPPanalysis{chan}{ii}{1};
                    tempLabel = dataForPPanalysis{chan}{ii}{4};
                    tempKeeps = dataForPPanalysis{chan}{ii}{5};
                    
                    tempTest = tempMag(tempLabel~=0 & tempKeeps);
                    uniqueLabel = unique(tempLabel(~isnan(tempLabel)));
                    
                    lengthType = length(tempTest);
                    
                    % check for empty
                    if ~isempty((tempTest))
                        lengthItems = lengthItems +lengthType;
                        vecType = repmat('null',lengthType,1);
                        vecTypeC = string(vecType)';
                        anovaType = [anovaType{:} vecTypeC];
                        
                        phaseVec = repmat(nan,lengthType,1)';
                        phaseDelivery = [phaseDelivery phaseVec];
                        
                        phaseBinned = phaseVec;
                        phaseDeliveryBinned = [phaseDeliveryBinned phaseBinned];
                        
                        
                        numTest = [];
                        tempTestOrdered = [];
                        typeResp = [];
                        
                        numTestTemp = repmat(['Null'],sum(tempLabel(tempKeeps) == uniqueLabel(2)),1);
                        numTest = [numTest; numTestTemp];
                        tempTestOrdered = [tempTestOrdered tempMag(tempLabel == uniqueLabel(2) & tempKeeps)];
                        
                        
                        typeResp = [tempTestOrdered];
                        totalMags = [totalMags typeResp];
                        
                        bTest = cellstr(numTest)';
                        numStims = [numStims{:} bTest];
                    end
                end
            end
            
            lengthToRep = lengthItems;
            sidString = repmat(sid,lengthToRep,1);
            sidCell = cellstr(sidString)';
            subjectNumInd = repmat(subjectNum,1,lengthToRep);
            chan = (subjectNum*100)+chan; % code channel differently to keep straight later
            chanLabels = [chanLabels repmat(chan,lengthToRep,1)'];
            betaLabels = [betaLabels repmat(beta,lengthToRep,1)'];
            betaSID = [betaSID{:} sidCell];
            stimLevelCombined = [stimLevelCombined repmat(stimLevel,lengthToRep,1)'];
            subjectNumVec = [subjectNumVec subjectNumInd];
        end
    end
end
%%
tableBetaStim = table(totalMags',stimLevelCombined',categorical(numStims)',categorical(betaLabels)',categorical(betaSID)',categorical(chanLabels)',categorical(subjectNumVec'),categorical(phaseDeliveryBinned'),categorical(anovaType'),...
    'VariableNames',{'magnitude','stimLevel','numStims','betaLabels','sid','channel','subjectNum','phaseClass','setToDeliverPhase'});
% group stats

statarray = grpstats(tableBetaStim,{'sid','numStims','channel','phaseClass'},{'mean','sem'},...
    'DataVars','magnitude');


statarray2 = grpstats(tableBetaStim,{'numStims','phaseClass'},{'mean','sem'},...
    'DataVars','magnitude');

statarrayCount = grpstats(tableBetaStim,{'subjectNum','numStims','setToDeliverPhase'},{'numel'},'DataVars','magnitude');

figure
grpstats(totalMags',{categorical(numStims)'},0.05)

%writetable(tableBetaStim,'betaStim_outputTable_50.csv');
return
% %%
% numSubj = 7;
% numDims = 4;
% j = 1;
%
% newOrder = [3 1 2 4];
% newOrder = repmat(newOrder,1,numSubj);
% subjMult = repmat([0:4:24],numDims,1);
% subjMult = subjMult(:);
% newOrder = newOrder+subjMult';
% statarray = statarray(newOrder,:);
% %%
% newSidOrder = [6 5 3 4 2 7 1];
% newSidOrder = repmat(newSidOrder,numDims,1);
% newSidOrder = newSidOrder(:);
% subjNumStim = repmat([1:4],1,numSubj);
%
% newSidOrder = 4*newSidOrder + subjNumStim' - 4;
% statarray = statarray(newSidOrder,:);

%%
[groupings,meansChannelSID] = findgroups(tableBetaStim(:,{'numStims','sid','channel','phaseClass'}));

meansChannelSID.mean = splitapply(@nanmean,tableBetaStim.magnitude,groupings);

[groupings2,meansChannelSID2] = findgroups(tableBetaStim(:,{'numStims','phaseClass'}));
meansChannelSID2.mean = splitapply(@nanmean,tableBetaStim.magnitude,groupings2);
%%
count = 1;

for name = unique(meansChannelSID.sid)'
    for chan = unique(meansChannelSID.channel(meansChannelSID.sid == name))'
        for numStimTrial = unique(meansChannelSID.numStims)'
            for typePhase = unique(meansChannelSID.phaseClass)'
                base = meansChannelSID.mean(meansChannelSID.sid == name & meansChannelSID.channel == chan & meansChannelSID.numStims == 'Base');
                percentDiff = 100*((meansChannelSID.mean(meansChannelSID.sid == name & meansChannelSID.channel == chan & meansChannelSID.numStims == numStimTrial & meansChannelSID.phaseClass == typePhase) - base)/base);
                meansChannelSID.percentDiff(meansChannelSID.sid == name & meansChannelSID.channel == chan & meansChannelSID.numStims == numStimTrial & meansChannelSID.phaseClass == typePhase) = percentDiff;
            end
        end
    end
end

figure
grpstats(meansChannelSID,{'numStims','phaseClass'},{'mean','sem'},...
    'DataVars','percentDiff')%hierarchicalBoxplot(anovaTotalMags,{categorical(anovanumStims),categorical(anovaBetaSID)})

grpstats(meansChannelSID,{'sid','numStims','phaseClass'},{'mean','sem'},...
    'DataVars','percentDiff')%hierarchicalBoxplot(anovaTotalMags,{categorical(anovanumStims),categorical(anovaBetaSID)})
%%
clearvars plotSummary plotSummaryLabels
phases = (meansChannelSID.phaseClass == '90');
ctNonBaseBool = meansChannelSID.numStims ~= 'Base';
ctNonBase = meansChannelSID.numStims(ctNonBaseBool);
% ct1= (meansChannelSID.numStims == '1<=Ct<=2');
% ct2 = (meansChannelSID.numStims == '3<=Ct<=4');
% ct3 = (meansChannelSID.numStims == 'Ct>=5');
%phasesSelected = (ct1 | ct2 | ct3);
phasesSelected = ctNonBaseBool;
% ct1sel = ct1(phasesSelected);
% ct2sel = ct2(phasesSelected);
% ct3sel = ct3(phasesSelected);
phasesAnova = phases(phasesSelected);

%%
dataInt = meansChannelSID.percentDiff(phasesSelected);

plotSummary{1} = dataInt(phasesAnova);
plotSummaryLabels{1} = zeros(size(plotSummary{1}));
for ii = 2:length(unique(meansChannelSID.numStims))
    plotSummaryLabels{1}( ctNonBase(phasesAnova) == ['Test ' num2str(ii-1)]) = ii-1;
    
end
% plotSummaryLabels{1}(ct2sel(phasesAnova)) = 1;
% plotSummaryLabels{1}(ct3sel(phasesAnova)) = 2;

plotSummary{2} = dataInt(~phasesAnova);
plotSummaryLabels{2} = zeros(size(plotSummary{2}));

for ii = 2:length(unique(meansChannelSID.numStims))
    plotSummaryLabels{2}( ctNonBase(~phasesAnova) == ['Test ' num2str(ii-1)]) = ii-1;
    
end
% plotSummaryLabels{2}(ct2sel(~phasesAnova)) = 1;
% plotSummaryLabels{2}(ct3sel(~phasesAnova)) = 2;

%%

labelsCount = zeros(size(phasesAnova));
for ii = 2:length(unique(meansChannelSID.numStims))
    labelsCount(ctNonBase ==['Test ' num2str(ii-1)]) = ii -1;
end

[p,tbs,stats,terms] = anovan(dataInt,{phasesAnova,labelsCount},...
    'varnames',{'phase','numStims'},'model','interaction');
figure
multcompare(stats,'Dimension',[2 1])

figure
multcompare(stats,'Dimension',[2])
%%
% phasesKruskal = phasesSelected;
% phasesKruskal(phasesKruskal & ct1sel) = 0;
% phasesKruskal(phasesKruskal & ct2sel) = 1;
% phasesKruskal(phasesKruskal & ct3sel) = 2;
% phasesKruskal(~phasesKruskal & ct1sel) = 3;
% phasesKruskal(~phasesKruskal & ct2sel) = 4;
% phasesKruskal(~phasesKruskal & ct3sel) = 5;
%
% [p,tbs,stats] = kruskalwallis(meansChannelSID.percentDiff,{phases,labelsCount});
%
% figure
% multcompare(stats,'Dimension',[1 2])
%
% figure
% multcompare(stats,'Dimension',[2])
%%
load('line_colormap.mat');
colors = cm(round(linspace(1, size(cm, 1), 4)), :);
colors = colors(2:end,:);
figure
subplot(1,2,1)
prettybar(plotSummary{1}, plotSummaryLabels{1}, colors, gcf);
set(gca, 'xtick', []);
ylabel('Percent Difference from baseline ');
ylim([-2 20])
set(gca,'fontsize',20)
title({'Hyperpolarizing conditioning','Percent change CEP from baseline'})

subplot(1,2,2)
prettybar(plotSummary{2}, plotSummaryLabels{2}, colors, gcf);
set(gca, 'xtick', []);
%ylabel('Percent difference from baseline');
ylim([-2 20])
title({'Depolarizing conditioning',' Percent change CEP from baseline'})

legend({'1<=Ct<=2','3<=Ct<=4','Ct>=5'})

set(gca,'fontsize',20)

%%
load('line_colormap.mat');
colors = cm(round(linspace(1, size(cm, 1), 4)), :);
colors = colors(2:end,:);
figure
subplot(1,2,1)
prettybox(plotSummary{1}, plotSummaryLabels{1}, colors,2,1);
set(gca, 'xtick', []);
ylabel('Percent Difference from baseline ');
%ylim([-10 40])
set(gca,'fontsize',20)
title({'Hyperpolarizing conditioning','Percent change CEP from baseline'})

subplot(1,2,2)
prettybox(plotSummary{2}, plotSummaryLabels{2}, colors,2,1);
set(gca, 'xtick', []);
%ylabel('Percent difference from baseline');
%ylim([-10 40])
title({'Depolarizing conditioning',' Percent change CEP from baseline'})

hLegend = legend(findall(gca,'Tag','Box'), {'1<=Ct<=2','3<=Ct<=4','Ct>=5'});


set(gca,'fontsize',20)


%                                     figure
%%
% fit glme
% glme = fitglme(tableBetaStim,'magnitude~numStims+stimLevel+phaseClass+(1|sid)+(-1 + numStims | sid) + (-1 + stimLevel | sid) + (-1 + phaseClass | sid)',...
%     'Distribution','Normal','Link','Identity','FitMethod','Laplace','DummyVarCoding','effects','EBMethod','Default')

% fit glme
glme = fitglme(tableBetaStim,'magnitude~numStims+stimLevel+phaseClass+(-1+numStims | sid) + (-1+stimLevel | sid) + (phaseClass | sid)',...
    'Distribution','Normal','Link','Identity','FitMethod','Laplace','DummyVarCoding','effects','EBMethod','Default')
%%
disp(glme)
anova(glme)
[psi,dispersion,stats] = covarianceParameters(glme)
psi
dispersion
stats


%
% test effect between different stim levels
%%
% between 3<CT<4 and Base
H = [0,0,0,1,-1,0];

[pVal,F,DF1,DF2] = coefTest(glme,H);
fprintf(['p value between 3<ct<4 and base = ' num2str(pVal) '\n']);
%%
% between 1<ct<2 and Base

H = [0,0,1,0,1,0];

[pVal,F,DF1,DF2] = coefTest(glme,H);
fprintf(['p value between 1<ct<2 and base = ' num2str(pVal) '\n']);
%%
% between >5 and base
H = [0,0,1,1,2,0];

[pVal,F,DF1,DF2] = coefTest(glme,H);
fprintf(['p value between >5 and base = ' num2str(pVal) '\n']);
%%
% between 1<ct<2 and >5

H = [0,0,2,1,1,0];

[pVal,F,DF1,DF2] = coefTest(glme,H);
fprintf(['p value between 1<ct<2 and >5 = ' num2str(pVal) '\n']);
%%
% between 3<CT<4 and > 5

H = [0,0,1,2,1,0];

[pVal,F,DF1,DF2] = coefTest(glme,H);
fprintf(['p value between 3<ct<4 and > 5 ' num2str(pVal) '\n']);
%%
% between PHASE

H = [0,0,0,0,0,-1];

[pVal,F,DF1,DF2] = coefTest(glme,H);
fprintf(['p value between phases ' num2str(pVal) '\n']);
%%
%
[pVal,F,DF1,DF2] = coefTest(glme)
%%
%
figure
plotResiduals(glme,'histogram','ResidualType','Pearson')
figure
plotResiduals(glme,'fitted','ResidualType','Pearson')
figure
plotResiduals(glme,'lagged','ResidualType','Pearson')

% %% MULTIPLE SUBJECTS - plot
% %
% % D5cd55 - subject 1
% % C91479 - subject 2
% % 7dbdec - subject 3
% % 9ab7ab - subject 4
% % 702d24 - subject 5
% % Ecb43e - subject 6
% % 0b5a2e - subject 7
%
% figure
%
% sem = table2array(statarray(:,{'sem_magnitude'}));
% means = table2array(statarray(:,{'mean_magnitude'}));
%
% load('line_red.mat');
% colors = flipud(cm(round(linspace(1, size(cm, 1), numDims)), :));
%
%
% k = 25;
%
%
% % generate error bars
%
% for ii = 1:height(statarray)
%
%     if j == 5
%         j = 1;
%     end
%
%     h = errorbar(ii,means(ii),sem(ii),'o','linew',3,'color',colors(j,:),'capsize',10);
%     ylim([0 800])
%
%     set(h, 'MarkerSize', 5, 'MarkerFaceColor', colors(j,:), ...
%         'MarkerEdgeColor', colors(j,:));
%     hold on
%
%     ax = gca;
%
%     if j ==2
%         text(ii+0.15,min(means(:,1))-6,sprintf([num2str(floor(ii/4)+1)]),'fontsize',14)
%
%     end
%
%     if mod(ii,4) == 0 & ii < 25
%         line = vline(ii+0.5);
%         line.Color = [0.5 0.5 0.5];
%     end
%     ax.FontSize = 12;
%     j = j+1;
% end
% ylabel('CCEP magnitude (\muV)','fontsize',14,'fontweight','bold')
% xlabel('Subject subdivided by number of conditioning pulses','fontsize',14,'fontweight','bold')
%
% % set(gca,'XtickLabel',{'','>5','3->4', '1->2','Baseline'},'fontsize',14,'fontweight','bold')
% ax.XTickLabelMode = 'manual';
% ax.XTick = [];
% title({'CCEP magnitude across Subjects';},'fontsize',16,'fontweight','bold')
%
%
%
% [h,icons,plots,legend_text] = legend({'Baseline','1-2','3-4','>5'},'fontsize',12);
%

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
% tableBetaStim = table(anovaTotalMags',anovaStimLevel',categorical(anovaType)',categorical(anovanumStims)',categorical(anovaBetaSID)',...
%     'VariableNames',{'magnitude','stimLevel','Type','numStims','sid'});
% glme = fitglme(tableBetaStim,'magnitude~numStims+Type+stimLevel+(1|sid)+(Type|sid)',...
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