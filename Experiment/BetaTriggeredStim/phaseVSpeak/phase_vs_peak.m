%% script to plot the peak to peak amplitude differences vs. actual phase of delivery
%
% David.J.Caldwell 10.2.2018

%close all;clear all;clc
baseDir = 'C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\PhaseDelivery';
addpath(baseDir);
baseDir2 = 'C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\PeaktoPeakEP';
addpath(baseDir2);

OUTPUT_DIR = 'C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\phaseVSpeak\plots';
TouchDir(OUTPUT_DIR);

SIDS = {'d5cd55','c91479','7dbdec','9ab7ab','702d24','ecb43e','0b5a2e','0b5a2ePlayback'};
valueSet = {{'s',180,1,[54 62],[1 49 58 59],[44 45 46 47 48 52 53 55 60 61 63],53},...
    {'m',[0 180],2,[55 56],[1 2 3 31 57],[31 39 40 47 48 63 64],64},...
    {'s',180,3,[11 12],[57],[4 5 10 13 18 19 20],4},...
    {'s',270,4,[59 60],[1 9 10 35 43],[41 42 43 44 45 49 50 51 52 53 57 58 61 62],51},...
    {'m',[90,270],5,[13 14],[23 27 28 29 30 32 44 52 60],[5],5},...
    {'t',[90,180],6,[56 64],[57:64],[46 48 54 55 63],55},...
    {'m',[90,270],7,[22 30],[24 25 29],[13 14 15 16 20 21 23 24 29 31 32 39 40],31},...
    {'m',[90,270],8,[22 30],[24 25 29],[13 14 15 16 20 21 23 24 29 31 32 39 40],31}};
M = containers.Map(SIDS,valueSet,'UniformValues',false);
%SIDS = {'d5cd55'}

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

modifier = '_51samps_12_20_60ms_randomstart';

%SIDS = {'d5cd55'};

%% plot EP modulation vs phase for all subjects
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
    chans(ismember(chans, badsTotal) | ~ismember(chans,goodEPs)) = [];
    Montage.MontageTokenized = {'Grid(1:64)'};
    
    markerMin = 50;
    markerMax = 200;
    minData = -1;
    maxData = 1;
    
    threshold = 0.7;
    
    
    load(strcat(subjid,'epSTATS-PP-sig.mat'))
    load([sid '_phaseDelivery_allChans' modifier '.mat']);

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
            [peakPhase,peakStd,markerSize] =  phase_delivery_accuracy_forPP(r_square_pos,...
                threshold,phase_at_0_pos,chans,desiredF(index),markerMin,markerMax,[],[]);
        elseif (strcmp(type,'m') || strcmp(type,'t')) && (index == 2)
            [peakPhase,peakStd,markerSize] =  phase_delivery_accuracy_forPP(r_square_neg,...
                threshold,phase_at_0_neg,chans,desiredF(2),markerMin,markerMax,[],[]);
        elseif (strcmp(type,'s') && index ==1) || (strcmp(type,'t') && index == 3)
            [peakPhase,peakStd,markerSize] =  phase_delivery_accuracy_forPP(r_square,...
                threshold,phase_at_0,chans,desiredF,markerMin,markerMax,[],[]);
        end
        
        w = nan(length(chans), length(indices));
        count = 1;
        for i = chans
            mags = 1e6*dataForPPanalysis{i}{index}{1};
            label= dataForPPanalysis{i}{index}{4};
            keeps = dataForPPanalysis{i}{index}{5};
            difference = 100*(nanmean(mags(label ==3 & keeps)) - nanmean(mags(label ==0 & keeps)))/nanmean(mags(label ==0 & keeps));
            w(count,index) = difference;
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
title('Phase of delivery and CEP modulation')
xlabel('Phase of delivery (degrees)')
ylabel('Percent change in EP size from baseline to >5 conditioning stimuli')
set(gca,'fontsize',18)

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
    
    markerMin = 50;
    markerMax = 200;
    minData = -1;
    maxData = 1;
    
    threshold = 0.3;
    
    load(strcat(subjid,'epSTATS-PP-sig.mat'))
    load([sid '_phaseDelivery_allChans' modifier '.mat']);
    
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
            [peakPhase,peakStd,markerSize] =  phase_delivery_accuracy_forPP(r_square_pos,...
                threshold,phase_at_0_pos,chans,desiredF(index),markerMin,markerMax,[],[]);
        elseif (strcmp(type,'m') || strcmp(type,'t')) && (index == 2)
            [peakPhase,peakStd,markerSize] =  phase_delivery_accuracy_forPP(r_square_neg,...
                threshold,phase_at_0_neg,chans,desiredF(2),markerMin,markerMax,[],[]);
        elseif (strcmp(type,'s') && index ==1) || (strcmp(type,'t') && index == 3)
            [peakPhase,peakStd,markerSize] =  phase_delivery_accuracy_forPP(r_square,...
                threshold,phase_at_0,chans,desiredF,markerMin,markerMax,[],[]);
        end
        
        w = nan(length(chans), length(indices));
        count = 1;
        for i = chans
            mags = 1e6*dataForPPanalysis{i}{index}{1};
            label= dataForPPanalysis{i}{index}{4};
            keeps = dataForPPanalysis{i}{index}{5};
            difference = 100*(nanmean(mags(label ==3 & keeps)) - nanmean(mags(label ==0 & keeps)))/nanmean(mags(label ==0 & keeps));
            w(count,index) = difference;
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
title('Phase of delivery and CEP modulation')
xlabel('Phase of delivery (degrees)')
ylabel('Percent change in EP size from baseline to >5 conditioning stimuli')
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
    
    markerMin = 50;
    markerMax = 200;
    minData = -1;
    maxData = 1;
    
    threshold = 0.3;
    
    load(strcat(subjid,'epSTATS-PP-sig.mat'))
    load([sid '_phaseDelivery_allChans' modifier '.mat']);
    
    fprintf(['running for subject ' sid '\n']);
    
    %%
    
    
    indices = 3;
    
    for index = 1:2
        
        if (strcmp(type,'m') || strcmp(type,'t')) && (index == 1)
            [peakPhase,peakStd,markerSize] =  phase_delivery_accuracy_forPP(r_square_pos,...
                threshold,phase_at_0_pos,chans,desiredF(index),markerMin,markerMax,[],[]);
        elseif (strcmp(type,'m') || strcmp(type,'t')) && (index == 2)
            [peakPhase,peakStd,markerSize] =  phase_delivery_accuracy_forPP(r_square_neg,...
                threshold,phase_at_0_neg,chans,desiredF(2),markerMin,markerMax,[],[]);
        end
        w = nan(length(chans), indices);
        count = 1;
        for i = chans
            mags = 1e6*dataForPPanalysis{i}{index}{1};
            label= dataForPPanalysis{i}{index}{4};
            keeps = dataForPPanalysis{i}{index}{5};
            difference = 100*(nanmean(mags(label ==3 & keeps)) - nanmean(mags(label ==0 & keeps)))/nanmean(mags(label ==0 & keeps));
            w(count,index) = difference;
            count = count +1;
        end
        
        hNull(countScatter) =  scatter(peakPhase,w(:,index),markerSize,plotColor(subjectNum,:),'filled');
        
    end
    countScatter = countScatter + 1;
    
    index = 3;
    w = nan(length(chans), length(indices));
    count = 1;
    for i = chans
        mags = 1e6*dataForPPanalysis{i}{index}{1};
        label= dataForPPanalysis{i}{index}{4};
        keeps = dataForPPanalysis{i}{index}{5};
        difference = 100*(nanmean(mags(label ==1 & keeps)) - nanmean(mags(label ==0 & keeps)))/nanmean(mags(label ==0 & keeps));
        w(count,index) = difference;
        count = count +1;
    end
    
    hNull(countScatter) =  scatter(peakPhase,w(:,index),125,plotColor(subjectNum+2,:),'d','filled');
    
end
xlim([0 360])
xticks([0 45 90 135 180 225 270 315 360])
legend(hNull,{'Subject 7',...
    'Subject 7 Null Control'})
title('Phase of delivery and CEP modulation')
xlabel('Phase of delivery (degrees)')
ylabel('Percent change in EP size from baseline to >5 conditioning stimuli')
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
    
    markerMin = 50;
    markerMax = 200;
    minData = -1;
    maxData = 1;
    
    threshold = 0.7;
    
    
    load(strcat(subjid,'epSTATS-PP-sig.mat'))
    load([sid '_phaseDelivery_allChans' modifier '.mat']);
    
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
            [peakPhase,peakStd,markerSize] =  phase_delivery_accuracy_forPP(r_square_pos,...
                threshold,phase_at_0_pos,chans,desiredF(index),markerMin,markerMax,[],[]);
            fDeliver = f_pos;
        elseif (strcmp(type,'m') || strcmp(type,'t')) && (index == 2)
            [peakPhase,peakStd,markerSize] =  phase_delivery_accuracy_forPP(r_square_neg,...
                threshold,phase_at_0_neg,chans,desiredF(2),markerMin,markerMax,[],[]);
            fDeliver = f_neg;
            
        elseif (strcmp(type,'s') && index ==1) || (strcmp(type,'t') && index == 3)
            [peakPhase,peakStd,markerSize] =  phase_delivery_accuracy_forPP(r_square,...
                threshold,phase_at_0,chans,desiredF,markerMin,markerMax,[],[]);
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
    
    markerMin = 50;
    markerMax = 200;
    minData = -1;
    maxData = 1;
    
    threshold = 0.8;
    
    
    load(strcat(subjid,'epSTATS-PP-sig.mat'))
    load([sid '_phaseDelivery_allChans' modifier '.mat']);
    
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
            [peakPhase,peakStd,markerSize] =  phase_delivery_accuracy_forPP(r_square_pos,...
                threshold,phase_at_0_pos_acaus,chans,desiredF(index),markerMin,markerMax,[],[]);
            fDeliver = f_pos;
        elseif (strcmp(type,'m') || strcmp(type,'t')) && (index == 2)
            [peakPhase,peakStd,markerSize] =  phase_delivery_accuracy_forPP(r_square_neg,...
                threshold,phase_at_0_neg_acaus,chans,desiredF(2),markerMin,markerMax,[],[]);
            fDeliver = f_neg;
            
        elseif (strcmp(type,'s') && index ==1) || (strcmp(type,'t') && index == 3)
            [peakPhase,peakStd,markerSize] =  phase_delivery_accuracy_forPP(r_square,...
                threshold,phase_at_0,chans,desiredF,markerMin,markerMax,[],[]);
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

