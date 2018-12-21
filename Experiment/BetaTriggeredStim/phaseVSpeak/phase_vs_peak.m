%% script to plot the peak to peak amplitude differences vs. actual phase of delivery
%
% David.J.Caldwell 10.2.2018

close all;clear all;clc
inputdir = getenv('OUTPUT_DIR');

baseDir = fullfile(inputdir,'\BetaTriggeredStim\PhaseDelivery');
addpath(baseDir);
baseDir2 = fullfile(inputdir,'\BetaTriggeredStim\PeaktoPeakEP');
addpath(baseDir2);

OUTPUT_DIR = fullfile(inputdir,'\BetaTriggeredStim\phaseVSpeak\plots');
TouchDir(OUTPUT_DIR);

SIDS = {'d5cd55','c91479','7dbdec','9ab7ab','702d24','ecb43e','0b5a2e','0b5a2ePlayback'};
% valueSet = {{'s',180,1,[54 62],[1 49 58 59],[44 45 46 47 48 52 53 55 60 61 63],53},...
%     {'m',[0 180],2,[55 56],[1 2 3 31 57],[39 40 47 48 63 64],64},...
%     {'s',180,3,[11 12],[57],[4 5 10 13 18 19 20],4},...
%     {'s',270,4,[59 60],[1 9 10 35 43],[41 42 43 44 45 49 50 51 52 53 57 58 61 62],51},...
%     {'m',[90,270],5,[13 14],[23 27 28 29 30 32 44 52 60],[5],5},...
%     {'t',[90,270],6,[56 64],[57:64],[46 48 54 55 63],55},...
%     {'m',[90,270],7,[22 30],[24 25 29],[13 14 15 16 20 21 23 31 32 39 40],31},...
%     {'m',[90,270],8,[22 30],[24 25 29],[13 14 15 16 20 21 23 31 32 39 40],31}};

valueSet = {{'s',180,1,[54 62],[1 49 58 59],[44 45 46 52 53 55 60 61 63],53,2.5},...
    {'m',[0 180],2,[55 56],[1 2 3 31 57],[47 48 64],64,3},...
    {'s',180,3,[11 12],[57],[4 5 10 13],4,3.5},...
    {'s',270,4,[59 60],[1 9 10 35 43],[50 51 52 53 58],51,0.75},...
    {'m',[90,270],5,[13 14],[23 27 28 29 30 32 44 52 60],[5],5,0.75},...
    {'t',[270,90,12345,12345],6,[56 64],[57:63],[47 48 54 55 63],55,1.75}...
    {'m',[90,270],7,[22 30],[24 25 29],[14 15 16 20 21 23 31 32 40],31,1.75},...
    {'m',[90,270],8,[22 30],[24 25 29],[14 15 16 20 21 23 31 32 40],31,1.75}};

M = containers.Map(SIDS,valueSet,'UniformValues',false);
plotColor = [
    [.65, .65, .65];...   % light gray         (0)
    [0.1, 0.74, 0.95];...  % deep sky-blue     (1)
    [0.95, 0.88, 0.05];... % gold/yellow       (2)
    [0.80, 0.05, 0.78];... % magenta           (3)
    [0.3, 0.8, 0.20];...   % lime green        (4)
    [0.95, 0.1, 0.1];...   % crimson red       (5)
    [0.64, 0.18, 0.93];... % blue-violet       (6)
    [0.88, 0.56, 0];...    % orange            (7)
    [0.4, 1.0, 0.7];...    % aquamarine        (8)
    [0.95, 0.88, 0.7];...  % salmon-yellow     (9)
    [0, 0.2, 1];...        % blue              (10)
    [1, 0.41, 0.7];...     % hot pink          (11)
    [0.5, 1, 0];...        % chartreuse        (12)
    [0.6, 0.39, 0.8];...   % amtheyist         (13)
    [0.82, 0.36, 0.36,];...% indian red        (14)
    [0.53, 0.8, 0.98];...  % light sky blue    (15)
    [0, 0.6, 0.1];...      % forest green      (16)
    [0.65, 0.95, 0.5];...  % light green       (17)
    [0.85, 0.6, 0.88];...  % light purple      (18)
    [0.90, 0.7, 0.7];...   % light red         (19)
    [0.2, 0.2, 0.6];...    % dark blue         (20)
    ];

SIDSint = {'d5cd55','c91479','7dbdec','9ab7ab','ecb43e','0b5a2e'};

plotColor = distinguishable_colors(9);

%modifierPhase = '_13samps_8_30_40ms_randomstart';

modifierPhase = '_51samps_12_20_40ms_randomstart';

%modifierPhase = '_13samps_10_30_40ms_randomstart';

modifierEP = '-reref-50';
%SIDS = {'d5cd55'};

% decide how to plot circles - std deviation or vector length
markerToUse = 'vecLength';
testStatistic = 'omnibus';

threshold = 0.7;
fThresholdMin = 12.01;
fThresholdMax = 19.99;
%
% fThresholdMin = 10;
% fThresholdMax = 29.99;
markerMin = 50;
markerMax = 500;
minData = 0;
maxData = 1;
epThresholdMaxMean = 150;
epThresholdMin = 25;
epThresholdMax = 1500;


%% plot EP modulation vs phase for all subjects
figTotal = figure;
hold on
figInd = figure;
countInd = 1;
hold on
for sid = SIDSint
    
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
    chans = [1:64];
    badsTotal = [stims bads];
    chans(ismember(chans, badsTotal) | ~ismember(chans,goodEPs)) = [];
    Montage.MontageTokenized = {'Grid(1:64)'};
    
    wInd = [];
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
    w = nan(length(chans), length(indices));
    
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
        
        count = 1;
        for i = chans
            mags = 1e6*dataForPPanalysis{i}{index}{1};
            mags(mags<epThresholdMin) = nan;
            mags(mags>epThresholdMax) = nan;
            
            label= dataForPPanalysis{i}{index}{4};
            keeps = dataForPPanalysis{i}{index}{5};
            maxLabel = max(unique(label)); % plot vs. maximum number of stimuli tested
            difference = 100*(nanmean(mags(label ==maxLabel & keeps)) - nanmean(mags(label ==0 & keeps)))/nanmean(mags(label ==0 & keeps));
            percentInd = 100*(mags(label ==maxLabel & keeps) - nanmean(mags(label ==0 & keeps)))/nanmean(mags(label ==0 & keeps));
            if nanmean(mags(label ==0 & keeps)) > epThresholdMaxMean
                w(count,index) = difference;
                wTotal(subjectNum,count,index) = difference;
                phaseTotal(subjectNum,count,index) = peakPhase(count);
            else
                w(count,index) = nan;
                wTotal(subjectNum,count,index) = nan;
                phaseTotal(subjectNum,count,index) = nan;
            end
            %  wInd{count,index} = percentInd;
            count = count +1;
        end
        
        %         peakPhaseRep = repmat(peakPhaseVec',1,1,size(wInd,3));
        %
        %         chanVec = repmat([1:size(wInd,1)]',1,size(wInd,2),size(wInd,3));
        %         indexVec = repmat([1:size(wInd,2)]',size(wInd,1),1,size(wInd,3));
        %
        %         dataTable = table(wInd(:),peakPhaseRep(:),chanVec(:),indexVec(:));
        %         dataFit = fitlm(dataTable,'Var1~Var2');
        %
        
        
        %         hold on
        %         h = plot(dataFit);
        %         s=findobj('type','legend');
        %         h(1).Color = plotColor(subjectNum,:);
        %         h(1).Marker = 'o';
        %         h(1).MarkerFaceColor = plotColor(subjectNum,:);
        %         delete(s)
        %         xlabel('');
        %         ylabel('');
        %         xlim([0 360])
        %         ylim([-30 60])
        %         xticks([0 45 90 135 180 225 270 315 360])
        %         title(['Subject '  num2str(subjectNum)])
        %         set(gca,'fontsize',14)
        
        figure(figTotal)
        hold on
        h(countInd) =  scatter(peakPhase,w(:,index),markerSize,plotColor(subjectNum,:),'filled');
        
        figure(figInd)
        grid on
        hold on
        subplot(3,2,countInd)
        ylim([-30 60])
        scatter(peakPhase,w(:,index),markerSize,plotColor(subjectNum,:),'filled');
        xlim([0 360])
        ylim([-30 60])
        hline(0,'k')
        
        xticks([0 45 90 135 180 225 270 315 360])
        title(['Subject '  num2str(subjectNum)])
        set(gca,'fontsize',14)
    end
    
    countInd = countInd + 1;
    
end
%%
figure(figTotal)
grid on
xlim([0 360])
xticks([0 45 90 135 180 225 270 315 360])
ylim([-30 60])
hline(0,'k')
legend(h,{'Subject 1',...
    'Subject 2',...
    'Subject 3',...
    'Subject 4',...
    'Subject 6',...
    'Subject 7'})
title('Phase of delivery and CEP modulation')
xlabel('Phase of delivery (degrees)')
ylabel({'EP percent change from baseline','to >5 conditioning stimuli'})
set(gca,'fontsize',24)

figure(figInd)
xlabel('Phase of delivery (degrees)')
ylabel([{'EP percent change from baseline',' to >5 conditioning stimuli'}])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% do the difference between 0-180 and 180-360
wTotal = wTotal(1:7,:,:);
phaseTotal = phaseTotal(1:7,:,:);

phaseTotalLess = phaseTotal((phaseTotal < 180) & (phaseTotal>0));
phaseTotalMore = phaseTotal((phaseTotal > 180) & (phaseTotal<365) );
wTotalLess = wTotal((phaseTotal < 180) & (phaseTotal>0));
wTotalMore = wTotal((phaseTotal > 180) & (phaseTotal<365) );


wTotalLess = wTotalLess(~isnan(wTotalLess));
wTotalMore = wTotalMore(~isnan(wTotalMore));
[h,p] = ttest2(wTotalLess,wTotalMore)

[p,h,stats] = ranksum(wTotalLess,wTotalMore)
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot EP modulation vs phase for subj. 7 with playback

figure
clearvars hPlayback1
hold on
countScatter = 1;

for sid = SIDS(end-1:end)
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
    chans = [1:64];
    badsTotal = [stims bads];
    chans(ismember(chans, badsTotal) | ~ismember(chans,goodEPs)) = [];
    Montage.MontageTokenized = {'Grid(1:64)'};
    
    
    
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
    wPlayback = nan(length(chans), length(indices));
    
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
        
        count = 1;
        for i = chans
            mags = 1e6*dataForPPanalysis{i}{index}{1};
            label= dataForPPanalysis{i}{index}{4};
            keeps = dataForPPanalysis{i}{index}{5};
            maxLabel = max(unique(label));
            
            difference = 100*(nanmean(mags(label ==3 & keeps)) - nanmean(mags(label ==0 & keeps)))/nanmean(mags(label ==0 & keeps));
            percentInd = 100*(mags(label ==maxLabel & keeps) - nanmean(mags(label ==0 & keeps)))/nanmean(mags(label ==0 & keeps));
            if nanmean(mags(label ==0 & keeps)) > epThresholdMax
                wPlayback(count,index) = difference;
                wTotalPlayback(subjectNum,count,index) = difference;
                phaseTotal(subjectNum,count,index) = peakPhase(count);
            else
                wPlayBack(count,index) = nan;
                wTotalPlayback(subjectNum,count,index) = nan;
                phaseTotal(subjectNum,count,index) = nan;
            end
            count  = count + 1;
            
        end
        
        hPlayback(countScatter) =  scatter(peakPhase,wPlayback(:,index),markerSize,plotColor(subjectNum,:),'filled');
        
    end
    
    countScatter = countScatter + 1;
    
end
xlim([0 360])
xticks([0 45 90 135 180 225 270 315 360])
hline(0,'k')
legend(hPlayback,{'Subject 7',...
    'Subject 7 Playback'})
title('Phase of delivery and CEP modulation')
xlabel('Phase of delivery (degrees)')
ylabel({'Percent change in EP size','from baseline to >5 conditioning stimuli'})
set(gca,'fontsize',18)

%% null fit for subject 7
figure
clearvars hNull
hold on
countScatter = 1;

for sid = SIDS(end-1)
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
    chans = [1:64];
    badsTotal = [stims bads];
    chans(ismember(chans, badsTotal) | ~ismember(chans,goodEPs)) = [];
    Montage.MontageTokenized = {'Grid(1:64)'};
    
    load(strcat(subjid,['epSTATS-PP-sig' modifierEP '.mat']))
    load([sid '_phaseDelivery_allChans' modifierPhase '.mat']);
    
    fprintf(['running for subject ' sid '\n']);
    
    %%
    indices = 3;
    
    for index = 1:2
        
        if (strcmp(type,'m') || strcmp(type,'t')) && (index == 1)
            [peakPhase,peakStd,peakLength,circularTest,markerSize] =  phase_delivery_accuracy_forPP(r_square_pos,...
                threshold,phase_at_0_pos,chans,desiredF(index),markerMin,markerMax,minData,maxData,markerToUse,testStatistic,f_pos,fThresholdMin,fThresholdMax);
        elseif (strcmp(type,'m') || strcmp(type,'t')) && (index == 2)
            [peakPhase,peakStd,peakLength,circularTest,markerSize] =  phase_delivery_accuracy_forPP(r_square_neg,...
                threshold,phase_at_0_neg,chans,desiredF(2),markerMin,markerMax,minData,maxData,markerToUse,testStatistic,f_neg,fThresholdMin,fThresholdMax);
        end
        wNull = nan(length(chans), indices);
        count = 1;
        for i = chans
            mags = 1e6*dataForPPanalysis{i}{index}{1};
            label= dataForPPanalysis{i}{index}{4};
            keeps = dataForPPanalysis{i}{index}{5};
            maxLabel = max(unique(label));
            
            difference = 100*(nanmean(mags(label ==maxLabel & keeps)) - nanmean(mags(label ==0 & keeps)))/nanmean(mags(label ==0 & keeps));
            if nanmean(mags(label ==0 & keeps)) > epThresholdMax
                wNull(count,index) = difference;
                wTotalNull(subjectNum,count,index) = difference;
                phaseTotal(subjectNum,count,index) = peakPhase(count);
            else
                wNull(count,index) = nan;
                wTotalNull(subjectNum,count,index) = nan;
                phaseTotal(subjectNum,count,index) = nan;
            end
            count = count +1;
        end
        
        hNull(countScatter) =  scatter(peakPhase,wNull(:,index),markerSize,plotColor(subjectNum,:),'filled');
        
    end
    countScatter = countScatter + 1;
    
    index = 3;
    wNull = nan(length(chans), length(indices));
    count = 1;
    for i = chans
        mags = 1e6*dataForPPanalysis{i}{index}{1};
        label= dataForPPanalysis{i}{index}{4};
        keeps = dataForPPanalysis{i}{index}{5};
        difference = 100*(nanmean(mags(label ==1 & keeps)) - nanmean(mags(label ==0 & keeps)))/nanmean(mags(label ==0 & keeps));
        if nanmean(mags(label ==0 & keeps)) > epThresholdMax
            wNull(count,index) = difference;
            wTotalNull(subjectNum,count,index) = difference;
            phaseTotal(subjectNum,count,index) = peakPhase(count);
        else
            wNull(count,index) = nan;
            wTotalNull(subjectNum,count,index) = nan;
            phaseTotal(subjectNum,count,index) = nan;
        end
        count = count +1;
    end
    
    hNull(countScatter) =  scatter(peakPhase,wNull(:,index),125,plotColor(subjectNum+2,:),'d','filled');
    
end
xlim([0 360])
ylim([-10 40])
hline(0,'k')
xticks([0 45 90 135 180 225 270 315 360])
legend(hNull,{'Subject 7',...
    'Subject 7 Null Control'})
title('Phase of delivery and CEP modulation')
xlabel('Phase of delivery (degrees)')
ylabel([{'Percent change in EP size from baseline'}])
set(gca,'fontsize',18)


%% all subjects fit all non-bad channels - see phases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
hold on
h = [];
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
    chans = [1:64];
    badsTotal = [stims bads];
    chans(ismember(chans, badsTotal)) = [];
    Montage.MontageTokenized = {'Grid(1:64)'};
    
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
            fDeliver = f_pos;
        elseif (strcmp(type,'m') || strcmp(type,'t')) && (index == 2)
            [peakPhase,peakStd,peakLength,circularTest,markerSize] =  phase_delivery_accuracy_forPP(r_square_neg,...
                threshold,phase_at_0_neg,chans,desiredF(2),markerMin,markerMax,minData,maxData,markerToUse,testStatistic,f_neg,fThresholdMin,fThresholdMax);
            fDeliver = f_neg;
            
        elseif (strcmp(type,'s') && index ==1) || (strcmp(type,'t') && index == 3)
            [peakPhase,peakStd,peakLength,circularTest,markerSize] =  phase_delivery_accuracy_forPP(r_square,...
                threshold,phase_at_0,chans,desiredF,markerMin,markerMax,minData,maxData,markerToUse,testStatistic,f,fThresholdMin,fThresholdMax);
            fDeliver = f;
            
        end
        
        w = nan(length(chans), length(indices));
        count = 1;
        for i = chans
            w(count,index) = nanmean(fDeliver(:,i));
            count = count +1;
        end
        h(subjectNum) =  scatter(peakPhase,w(:,index),markerSize,plotColor(subjectNum,:),'filled');
        
    end
    
    
end
xlim([0 360])
xticks([0 45 90 135 180 225 270 315 360])
legend([h],{'Subject 1',...
    'Subject 2',...
    'Subject 3',...
    'Subject 4',...
    'Subject 5',...
    'Subject 6',...
    'Subject 7',...
    'Subject 7 Playback'})
title('Phase of delivery and frequency of fit beta')
xlabel('Phase of delivery (degrees)')
ylabel('Mean frequency of delivery')
set(gca,'fontsize',18)



%% subject 7 - with/without playback
% fit all non-bad channels - see phases playback only
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure
hold on
hPlayback = [];
countScatter = 1;
for sid = SIDS(end-1:end)
    
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
    chans = [1:64];
    badsTotal = [stims bads];
    chans(ismember(chans, badsTotal)) = [];
    Montage.MontageTokenized = {'Grid(1:64)'};
    
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
                threshold,phase_at_0_pos_acaus,chans,desiredF(index),markerMin,markerMax,minData,maxData,markerToUse,testStatistic,f_pos,fThresholdMin,fThresholdMax);
            fDeliver = f_pos;
        elseif (strcmp(type,'m') || strcmp(type,'t')) && (index == 2)
            [peakPhase,peakStd,peakLength,circularTest,markerSize] =  phase_delivery_accuracy_forPP(r_square_neg,...
                threshold,phase_at_0_neg_acaus,chans,desiredF(2),markerMin,markerMax,minData,maxData,markerToUse,testStatistic,f_neg,fThresholdMin,fThresholdMax);
            fDeliver = f_neg;
            
        elseif (strcmp(type,'s') && index ==1) || (strcmp(type,'t') && index == 3)
            [peakPhase,peakStd,peakLength,circularTest,markerSize] =  phase_delivery_accuracy_forPP(r_square,...
                threshold,phase_at_0,chans,desiredF,markerMin,markerMax,minData,maxData,markerToUse,testStatistic,f,fThresholdMin,fThresholdMax);
            fDeliver = f;
            
        end
        
        w = nan(length(chans), length(indices));
        count = 1;
        for i = chans
            w(count,index) = nanmean(fDeliver(:,i));
            count = count +1;
        end
        
        hPlayback(countScatter) =  scatter(peakPhase,w(:,index),markerSize,plotColor(subjectNum,:),'filled');
        
    end
    countScatter = countScatter + 1;
    
    
end
xlim([0 360])
xticks([0 45 90 135 180 225 270 315 360])
legend(hPlayback,{'Subject 7',...
    'Subject 7 Playback'})
title('Phase of delivery and frequency of fit beta')
xlabel('Phase of delivery (degrees)')
ylabel('Mean frequency of delivery')
set(gca,'fontsize',18)

