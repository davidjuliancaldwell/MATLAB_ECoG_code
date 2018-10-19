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
    {'m',[90,270],7,[22 30],[24 25 29],[13 14 15 16 20 21 23 24 29 31 32 39 40],31,1.75},...
    {'m',[90,270],8,[22 30],[24 25 29],[13 14 15 16 20 21 23 24 29 31 32 39 40],31,1.75}};
M = containers.Map(SIDS,valueSet,'UniformValues',false);
SIDS = {'0b5a2e','0b5a2ePlayback'};

modifier = '-reref';

%%
anovaBetaMags5 = [];
anovaBetaMags3 = [];
anovaBetaMags1 = [];
anovaBetaBase = [];
anovaBetaSID = {};
anovaNumStims = {};
anovaTotalMags = [];
anovaChan = {};
anovaType = {};


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
    
    load(strcat(subjid,['epSTATS-PP-sig' modifier '.mat']))
    % here's where I pick those channels!
    chans = [14];
    chans = 31;
    % figure out number of test conditions
    numTypes = length(dataForPPanalysis{betaChan});
    
    if strcmp(sid,'0b5a2e') || strcmp(sid,'0b5a2ePlayback') || strcmp(sid,'ecb43e')
        nullType = 3;
        
    else
        nullType = NaN;
    end
    
    % cells, rather than stacked, of responses for given num stimuli
    
    for chan = chans
        % for each channel, a single stacked vector of all of the responses for a given number of stimuli
        tB = [];
        t1 = [];
        t2 = [];
        t3 = [];
        tN = [];
                lengthItems = 0;

        for i = 1:numTypes
            
            if i ~= nullType
                tempMag = 1e6*dataForPPanalysis{chan}{i}{1};
                tempLabel = dataForPPanalysis{chan}{i}{4};
                tempKeeps = dataForPPanalysis{chan}{i}{5};
                
                tempBase = tempMag(tempLabel==0 & tempKeeps);
                tempResp1 = tempMag(tempLabel==1 & tempKeeps);
                tempResp2 =tempMag(tempLabel==2 & tempKeeps);
                tempResp3 = tempMag(tempLabel==3 & tempKeeps);
                
                if (strcmp(subdir,'NeuroModulation') | strcmp(subdir,'NeuroModulationV2')| strcmp(subdir,'NeuroModulationV4')  | strcmp(subdir,'NeuroModulationV3')) & strcmp(answer,'zscore')
                    if i == 1
                        tB = tempBase;
                        tB = [tB tempBase'];
                    end
                    t1 = [t1 tempResp1'];
                    t2 = [t2 tempResp2'];
                    t3 = [t3 tempResp3'];
                else
                    t1 = [t1 tempResp1];
                    t2 = [t2 tempResp2];
                    t3 = [t3 tempResp3];
                end
                
                if i == 1
                    lengthType = length(tempBase)+length(tempResp1)+length(tempResp2)+length(tempResp3);
                else
                    lengthType = length(tempResp1)+length(tempResp2)+length(tempResp3);
                    
                end
                lengthItems = lengthItems +lengthType;
                vecType = repmat(desiredF(i),lengthType,1);
                vecTypeC = string(vecType)';
                anovaType = [anovaType{:} vecTypeC];
                
                % 6-17-2016 - have to transpose for 'subdir'
                if i ==1
                    if (strcmp(subdir,'NeuroModulation')| strcmp(subdir,'NeuroModulationV4') | strcmp(subdir,'NeuroModulationV2')  | strcmp(subdir,'NeuroModulationV3')) & strcmp(answer,'zscore')
                        typeResp = [tempResp3' tempResp2' tempResp1' tempBase'];
                    else
                        typeResp = [tempResp3 tempResp2 tempResp1 tempBase];
                    end
                    anovaTotalMags = [anovaTotalMags typeResp];
                    num5S = repmat('Ct>=5',length(tempResp3),1);
                    num3S= repmat('3<=Ct<=4',length(tempResp2),1);
                    num1S = repmat('1<=Ct<=2',length(tempResp1),1);
                    numBaseS = repmat('Base',length(tempBase),1);
                    
                    b5C = cellstr(num5S)';
                    b3C = cellstr(num3S)';
                    b1C = cellstr(num1S)';
                    BC = cellstr(numBaseS)';
                    anovaNumStims = [anovaNumStims{:} b5C b3C b1C BC];
                    
                else
                    if (strcmp(subdir,'NeuroModulation')| strcmp(subdir,'NeuroModulationV4') | strcmp(subdir,'NeuroModulationV2')  | strcmp(subdir,'NeuroModulationV3')) & strcmp(answer,'zscore')
                        typeResp = [tempResp3' tempResp2' tempResp1'];
                    else
                        typeResp = [tempResp3 tempResp2 tempResp1];
                    end
                    anovaTotalMags = [anovaTotalMags typeResp];
                    num5S = repmat('Ct>=5',length(tempResp3),1);
                    num3S= repmat('3<=Ct<=4',length(tempResp2),1);
                    num1S = repmat('1<=Ct<=2',length(tempResp1),1);
                    
                    b5C = cellstr(num5S)';
                    b3C = cellstr(num3S)';
                    b1C = cellstr(num1S)';
                    anovaNumStims = [anovaNumStims{:} b5C b3C b1C];
                end
                
            end
        end
        
        
        lengthToRep = lengthItems;
        sidString = repmat(sid,lengthToRep,1);
        sidCell = cellstr(sidString)';
        anovaBetaSID = [anovaBetaSID{:} sidCell];
        
        
    end
end
%%
% figure
[p,tbl,stats] = anovan(anovaTotalMags,{anovaNumStims,anovaBetaSID},'varnames',{'anovaNumStims','anovaBetaSID'},'model','interaction')

figure
[cM,mM,hM,gnamesM] = multcompare(stats,'Dimension',[1 2])

% flip order of playback
mMnew = zeros(size(mM));
numSubj = 2;
k = 5;
% reshape mM to match order of subjects
for i = 0:numSubj-1
    mMnew((4*i+1:(4*i)+4),:) = mM(k:k+3,:);
    k = k - 4;
end

mM = mMnew;
j = 1;
load('line_blue.mat');
colors = cm(round(linspace(1, size(cm, 1), length(mM)/2)), :);

for i = 1:length(mM)
    
    if j == 5
        j = 1;
        load('line_green.mat');
        colors = cm(round(linspace(1, size(cm, 1), length(mM)/2)), :);
    end
    
    h = errorbar(i,flip(mM(length(mM)-i+1,1)),flip(mM(length(mM)-i+1,2)),'o','linestyle','none','linew',3,'color',colors(j,:));
    
    set(h, 'MarkerSize', 5, 'MarkerFaceColor', colors(j,:), ...
        'MarkerEdgeColor', colors(j,:));
    hold on
    ylims = [300 600];
    ylim(ylims)
    
    if i == 1
        text(i-0.5,ylims(1)+20,'Beta-triggered stimulation','fontsize',14)
    end
    
    if i == 6
        text(i-0.5,ylims(1)+20,'Playback condition','fontsize',14)
    end
    
    if mod(i,4) == 0 & i < 7
        line = vline(i+0.5);
        line.Color = [0.5 0.5 0.5];
    end
    
    j = j+1;
    
    
    if i == length(mM)-1
        
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

