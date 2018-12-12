%% Ok - time to look at everyone
close all;clear all;clc
Z_Constants;
SUB_DIR = fullfile(myGetenv('subject_dir'));
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'));

for i = 2:length(SIDS)-1
    sid = SIDS{i};
    switch sid
        case 'd5cd55'
            load(fullfile(OUTPUT_DIR,'BetaTriggeredStim','CSNESiteVisit','d5cd55epSTATSsig'))
            stims = [54 62];
                        goods = [35 36 37 44 45 46 52 53 55 60 61 63];

            betaChan = 53;
        case 'c91479'
            load(fullfile(OUTPUT_DIR,'BetaTriggeredStim','CSNESiteVisit','c91479epSTATSsig'))
            betaChan = 64;
            stims = [55 56];
                        goods = [38 39 40 46 47 48 62 64];

        case '7dbdec'
            load(fullfile(OUTPUT_DIR,'BetaTriggeredStim','CSNESiteVisit','7dbdecepSTATSsig'))
            stims = [11 12];
                        goods = [4 5 10 13 21 22 23];

            betaChan = 4;
        case '9ab7ab'
            load(fullfile(OUTPUT_DIR,'BetaTriggeredStim','CSNESiteVisit','9ab7abepSTATSsig'))
            betaChan = 51;
            stims = [59 60];
                        goods = [42 43 50 51 52 53 57 58];

        case '702d24'
            load(fullfile(OUTPUT_DIR,'BetaTriggeredStim','CSNESiteVisit','702d24epSTATSsig'))
            betaChan = 5;
            stims = [13 14];
                        goods = [4 5 6 12 20 21 22];

                    case 'ecb43e'
                        load(fullfile(OUTPUT_DIR,'BetaTriggeredStim','CSNESiteVisit','ecb43eepSTATSsig'))
                        betaChan = 55;
                        stims = [56 64];
                       goods = [55 63 54 46 47 48 46];

            
        case '0b5a2e'
            load(fullfile(OUTPUT_DIR,'BetaTriggeredStim','CSNESiteVisit','0b5a2eepSTATSsig'))
            betaChan = 31;
            stims = [22 30];
                        goods = [12 13 14 15 16 21 23 31 32 39 40];

        case '0b5a2ePlayback'
            load(fullfile(OUTPUT_DIR,'BetaTriggeredStim','CSNESiteVisit','0b5a2ePlaybackepSTATSsig'))
            betaChan = 31;
            stims = [22 30];
                        goods = [12 13 14 15 16 21 23 31 32 39 40];

    end
    
    
    load tTemp.mat
    subjid = sid;
    if (strcmp(sid,'0b5a2ePlayback'))
        load(fullfile(getSubjDir('0b5a2e'), 'trodes.mat'));
    else
        load(fullfile(getSubjDir(subjid),'trodes.mat'))
    end
    
    
    locs = Grid;
%     
%     % scatter plot of electrode locations
%     figure
%     c = linspace(1,10,size(locs,1));
%     
%     % take labeling from plot dots direct
%     h = scatter3(locs(:,1),locs(:,2),locs(:,3),[100],c,'filled');
%     
%     
%     gridSize = 64;
%     
%     trodeLabels = [1:gridSize];
%     for chan = 1:gridSize
%         txt = num2str(trodeLabels(chan));
%         t = text(locs(chan,1),locs(chan,2),locs(chan,3),txt,'FontSize',10,'HorizontalAlignment','center','VerticalAlignment','middle');
%         set(t,'clipping','on');
%     end
%     
%     % plot cortex too
%     figure
%     sidToPlot = subjid;
%     if strcmp(subjid,'0b5a2ePlayback')
%         sidToPlot = '0b5a2e';
%     end
%     PlotCortex(sidToPlot,'l')
%     hold on
%     h = scatter3(locs(:,1),locs(:,2),locs(:,3),100,c,'filled')
%     for chan = 1:gridSize
%         txt = num2str(trodeLabels(chan));
%         t = text(locs(chan,1),locs(chan,2),locs(chan,3),txt,'FontSize',10,'HorizontalAlignment','center','VerticalAlignment','middle');
%         set(t,'clipping','on');
%     end

% DJC 5-30-2016 additions to look at timing 

distances = matrixDist(locs);


betaDist = channelExtract(distances,betaChan);
stim1Dist = channelExtract(distances,stims(1));
stim2Dist = channelExtract(distances,stims(2));

chans = [1:64];
logChans = chans;
% logChans(stims) = 0;
logChans(goods) = 0;
logChans = ~logical(logChans);

% for greater than 5 stims 
for chan = chans
    if (chan~=stims)
        if strcmp(sid,'0b5a2e') || strcmp(sid,'0b5a2ePlayback')
            
        type1 = cell2mat([CCEPbyNumStim{chan}{1}{1:3}]);
        type2 = cell2mat([CCEPbyNumStim{chan}{2}{1:3}]);
        BigAveResp(chan) = (type1(14)+type2(14))/2;
        latencyResp(chan) = (type1(15)+type2(15))/2;
        else
            % temporary work around DJC 5-30-2016 
                    type1 = cell2mat([CCEPbyNumStim{chan}{1}{1:3}]);
        BigAveResp(chan) = type1(14);
        latencyResp(chan) = type1(15);

        end
    end
end

% for greater than 5 stims 
figure
scatter(betaDist(logChans),BigAveResp(logChans))
title([sid,' CCEP magnitude response vs. distance from beta channel'])

figure
scatter(betaDist(logChans),latencyResp(logChans))
title([sid, ' CCEP latency vs. distance from beta channel'])

figure
[f,gof] = fit(betaDist(logChans)',latencyResp(logChans)','exp1');
plot(f,betaDist(logChans),latencyResp(logChans))
title([sid, ' CCEP latency vs. distance from beta channel - exponential fit'])

figure
[f,gof] = fit(betaDist(logChans)',BigAveResp(logChans)','exp1');
plot(f,betaDist(logChans),BigAveResp(logChans))
title([sid,' CCEP magnitude response vs. distance from beta channel - exponential fit'])

gof;

figure
[f,gof] = fit(betaDist(logChans)',BigAveResp(logChans)','poly3');
plot(f,betaDist(logChans),BigAveResp(logChans))
title([sid,' CCEP magnitude response vs. distance from beta channel - polynomial 3 fit'])

gof;


end
