%% 3/14/2017 - DJC - script to generate beta stim figures
% based off live script - BetaANOVAmultipleSubj.mlx

%close all;clear all;clc
clear all;
Z_Constants;
SUB_DIR = fullfile(myGetenv('subject_dir'));
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'));

%% parameters

SIDS = {'d5cd55','c91479','7dbdec','9ab7ab','702d24','ecb43e','0b5a2e','0b5a2ePlayback'};
valueSet = {{'s',180,1,[54 62],[1 49 58 59],[44 45 46 47 48 52 53 55 60 61 63],53,2.5},...
    {'m',[0 180],2,[55 56],[1 2 3 31 57],[31 39 40 47 48 63 64],64,3},...
    {'s',180,3,[11 12],[57],[4 5 10 13 18 19 20],4,3.5},...
    {'s',270,4,[59 60],[1 9 10 35 43],[41 42 43 44 45 49 50 51 52 53 57 58 61 62],51,0.75},...
    {'m',[90,270],5,[13 14],[23 27 28 29 30 32 44 52 60],[5],5,0.75},...
    {'t',[270,90],6,[56 64],[57:64],[46 48 54 55 63],55,1.75}...
    {'m',[90,270],7,[22 30],[24 25 29],[13 14 15 16 20 21 23 31 32 39 40],31,1.75},...
    {'m',[90,270],8,[22 30],[24 25 29],[13 14 15 16 20 21 23 31 32 39 40],31,1.75}};
M = containers.Map(SIDS,valueSet,'UniformValues',false);
SIDS = {'0b5a2e','0b5a2ePlayback'};

modifierEP = '-reref-50';
modifierPhase = '_51samps_12_20_40ms_randomstart';

% decide how to plot circles - std deviation or vector length
markerToUse = 'vecLength';
testStatistic = 'omnibus';

threshold = 0.7;
%fThresholdMin = 12.01;
%fThresholdMax = 19.99;

fThresholdMin = 12.01;
fThresholdMax = 19.99;

markerMin = 50;
markerMax = 200;
minData = 0;
maxData = 1;
epThresholdMag = 100;

%%
betaSID = {};
numStims = {};
totalMags = [];
anovaChan = {};
anovaType = {};
phaseDelivery = [];
phaseDeliveryBinned = [];

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
    epThresholdMag = 100;
    
    load([sid '_phaseDelivery_allChans' modifierPhase '.mat']);
    load(strcat(subjid,['epSTATS-PP-sig' modifierEP '.mat']))
    % here's where I pick those channels!
    chans = [14];
    % chans = 31;
    % figure out number of test conditions
    numTypes = length(dataForPPanalysis{betaChan});
    
    if strcmp(sid,'0b5a2e') || strcmpi(sid,'0b5a2ePlayback') || strcmp(sid,'ecb43e')
        nullType = 3;
        
    else
        nullType = NaN;
    end
    
    % cells, rather than stacked, of responses for given num stimuli
    
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
        lengthItems = 0;
        
        %%%%%%%%%%%%%%%%%%%%% screen
        tempMagScreen = 1e6*dataForPPanalysis{chan}{1}{1};
        tempLabelScreen = dataForPPanalysis{chan}{1}{4};
        tempKeepsScreen = dataForPPanalysis{chan}{1}{5};
        
        if nanmean(tempMagScreen(tempLabelScreen ==0 & tempKeepsScreen)) > epThresholdMag
            
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
                    
                    phaseVecChosen = peakPhaseVec(ii);
                    phaseVec = repmat(phaseVecChosen,lengthType,1)';
                    phaseDelivery = [phaseDelivery phaseVec];
                    
                    phaseBinned = phaseVec;
                    %                     if any(phaseBinned > 180)
                    %                         phaseBinned(:) = 270;
                    %                     else
                    %                         phaseBinned(:) = 90;
                    %                     end
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
                    
                end
            end
  
            lengthToRep = lengthItems;
            sidString = repmat(sid,lengthToRep,1);
            sidCell = cellstr(sidString)';
            betaSID = [betaSID{:} sidCell];
          
        end
    end
end
%%
% figure
[p,tbl,stats] = anovan(totalMags,{numStims,betaSID},'varnames',{'numStims','betaSID'},'model','interaction')

figure
[cM,mM,hM,gnamesM] = multcompare(stats,'Dimension',[1 2])

figure
% flip order of playback
%mMnew = zeros(size(mM));
numSubj = 2;
k = 5;
% % reshape mM to match order of subjects
% for ii = 0:numSubj-1
%     mMnew((4*ii+1:(4*ii)+4),:) = mM(k:k+3,:);
%     k = k - 4;
% end

%mM = mMnew;
j = 1;
load('line_blue.mat');
colors = cm(round(linspace(1, size(cm, 1), length(mM)/2)), :);

for ii = 1:length(mM)
    
    if j == 5
        j = 1;
        load('line_green.mat');
        colors = cm(round(linspace(1, size(cm, 1), length(mM)/2)), :);
    end
    
    h = errorbar(ii,mM(ii,1),mM(ii,2),'o','linestyle','none','linew',3,'color',colors(j,:));
   %   h = errorbar(ii,mM(:,1),flip(mM(length(mM)-ii+1,2)),'o','linestyle','none','linew',3,'color',colors(j,:));

    set(h, 'MarkerSize', 5, 'MarkerFaceColor', colors(j,:), ...
        'MarkerEdgeColor', colors(j,:));
    hold on
    ylims = [300 600];
    ylim(ylims)
    
    if ii == 1
        text(ii-0.5,ylims(1)+20,'Beta-triggered stimulation','fontsize',14)
    end
    
    if ii == 6
        text(ii-0.5,ylims(1)+20,'Playback condition','fontsize',14)
    end
    
    if mod(ii,4) == 0 & ii < 7
        line = vline(ii+0.5);
        line.Color = [0.5 0.5 0.5];
    end
    
    j = j+1;
    
    
    if ii == length(mM)-1
        
        [h,icons,plots,legend_text] = legend({'Baseline','1-2','3-4','>5'},'fontsize',12);
        
    end
end
ylabel('CEP Magnitude (\muV)','fontsize',14,'fontweight','bold')
xlabel('Subject subdivided by number of conditioning pulses','fontsize',14,'fontweight','bold')

ax = gca;
ax.XTickLabelMode = 'manual';
ax.XTick = [];
%ax.XTickLabel = {'Baseline','1->2','3->4','>5' }
ax.FontSize = 12;
% ax.FontWeight = 'bold';
xlim([0 9]);
% set(gca,'XtickLabel',{'','>5','3->4', '1->2','Baseline'},'fontsize',14,'fontweight','bold')
title({'Comparison between Activity Dependent and',['Playback condition - channel ' num2str(chans)] },'fontsize',16,'fontweight','bold')

