%% script to plot phase distributions of beta triggered stim signal
% takes in fit signals from all subjects, for all channels, and generates
% plots

% David.J.Caldwell 8.26.2018
%%
close all;clear all;clc
baseDir = 'C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\BetaStimManuscript_4_30-2018\';
addpath(baseDir);

OUTPUT_DIR = 'C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\BetaStimManuscript_4_30-2018\allChans';
TouchDir(OUTPUT_DIR);

SIDS = {'d5cd55','c91479','7dbdec','9ab7ab','702d24','ecb43e','0b5a2e','0b5a2ePlayback'};
valueSet = {{'s',180,1,[54 62],[1 49 58 59]},{'m',[0 180],2,[55 56],[2 3 31 57]},{'s',180,3,[11 12],[57]},...
    {'s',270,4,[59 60],[1 9 10 35 43]},{'m',[90,270],5,[13 14],[23 27 28 29 30 32 44 52 60]},...
    {'m',[90,180],6,[56 64],[57:64]},{'m',[90,270],7,[22 30],[17 18 19]},{'m',[90,270],8,[22 30],[17 18 19]}};
M = containers.Map(SIDS,valueSet,'UniformValues',false);

SIDS = {'d5cd55','c91479','7dbdec','9ab7ab'};
SIDS = {'c91479','7dbdec','9ab7ab'};

%gcp;  %parallel pool
%
% settings
hilbPlot = 0;
acausalPlot = 1;
rawPlot = 1;
saveIt = 0;
closeAll = 0;

%
markerSizeFunc= @(minNew,maxNew,minData,maxData,val) (maxNew-minNew)*(val-minData)/(maxData-minData)+minNew;


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
    chans = [1:64];
    badsTotal = [stims bads];
    chans(ismember(chans, badsTotal)) = [];
    Montage.MontageTokenized = {'Grid(1:64)'};
    locs = trodeLocsFromMontage(sid, Montage, false);
    
    markerMin = 1;
    markerMax = 30;
    
    threshold = 0;
    
    
    if strcmp(type,'m')
        
        if rawPlot
            figure
            rSquareThresh_pos = (r_square_pos) > threshold;
            signalType = 'unfiltered';
            phase_at_0_screened = phase_at_0_pos;
            phase_at_0_screened(~rSquareThresh_pos) = nan;
            meanPhase = nanmean(phase_at_0_screened,1);
            weights = (desiredF(1))-rad2deg(meanPhase(chans));
            markerSize = markerSizeFunc(markerMin,markerMax,-1,1,mean(r_square_pos(:,chans),1));
            PlotDotsDirect(sid, locs(chans,:), weights, 'b',...
                [-max(abs(weights)) max(abs(weights))], markerSize,'america',[],false,false)
            load('america'); % needs to be the same as what was used in the function call above
            colormap(cm);
            cbar = colorbar;
            cbar.Label.String = 'difference in degrees from desired frequency';
            PlotBrainJustDots(sid,{stims},[0 0 0],true);
            title({['Subject ' num2str(subjectNum) ' '  signalType ' signal stimulation delivery difference'],['from desired frequency of ' num2str(desiredF) char(176) ]})
            
            figure
            rSquareThresh_neg = (r_square_neg) > threshold;
            
            signalType = 'unfiltered';
            phase_at_0_screened = phase_at_0_neg;
            phase_at_0_screened(~rSquareThresh_neg) = nan;
            meanPhase = nanmean(phase_at_0_screened,1);
            weights = (desiredF(2))-rad2deg(meanPhase(chans));
            markerSize = markerSizeFunc(markerMin,markerMax,-1,1,mean(r_square_neg(:,chans),1));
            PlotDotsDirect(sid, locs(chans,:), weights, 'b',...
                [-max(abs(weights)) max(abs(weights))], markerSize,'america',[],false,false)
            load('america'); % needs to be the same as what was used in the function call above
            colormap(cm);
            cbar = colorbar;
            cbar.Label.String = 'difference in degrees from desired frequency';
            PlotBrainJustDots(sid,{stims},[0 0 0],true);
            title({['Subject ' num2str(subjectNum) ' '  signalType ' signal stimulation delivery difference'],['from desired phase of ' num2str(desiredF) char(176) ]})
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if acausalPlot
            figure
            rSquareThresh_pos_acaus = (r_square_pos_acaus) > threshold;
            signalType = 'filtered';
            phase_at_0_screened = phase_at_0_pos_acaus;
            phase_at_0_screened(~rSquareThresh_pos_acaus) = nan;
            meanPhase = nanmean(phase_at_0_screened,1);
            weights = (desiredF(1))-rad2deg(meanPhase(chans));
            markerSize = markerSizeFunc(markerMin,markerMax,-1,1,mean(r_square_pos_acaus(:,chans),1));
            PlotDotsDirect(sid, locs(chans,:), weights, 'b',...
                [-max(abs(weights)) max(abs(weights))], markerSize,'america',[],false,false)
            load('america'); % needs to be the same as what was used in the function call above
            colormap(cm);
            cbar = colorbar;
            cbar.Label.String = 'difference in degrees from desired frequency';
            PlotBrainJustDots(sid,{stims},[0 0 0],true);
            title({['Subject ' num2str(subjectNum) ' '  signalType ' signal stimulation delivery difference'],['from desired frequency of ' num2str(desiredF) char(176) ]})
            
            figure
            rSquareThresh_neg_acaus = (r_square_neg_acaus) > threshold;
            signalType = 'filtered';
            phase_at_0_screened = phase_at_0_neg_acaus;
            phase_at_0_screened(~rSquareThresh) = nan;
            meanPhase = nanmean(phase_at_0_screened,1);
            weights = (desiredF(2))-rad2deg(meanPhase(chans));
            markerSize = markerSizeFunc(markerMin,markerMax,-1,1,mean(r_square_neg_acaus(:,chans),1));
            PlotDotsDirect(sid, locs(chans,:), weights, 'b',...
                [-max(abs(weights)) max(abs(weights))], markerSize,'america',[],false,false)
            load('america'); % needs to be the same as what was used in the function call above
            colormap(cm);
            cbar = colorbar;
            cbar.Label.String = 'difference in degrees from desired frequency';
            PlotBrainJustDots(sid,{stims},[0 0 0],true);
            title({['Subject ' num2str(subjectNum) ' '  signalType ' signal stimulation delivery difference'],['from desired phase of ' num2str(desiredF) char(176) ]})
            
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif strcmp(type,'s')
        
        if rawPlot
            %%
            figure
            signalType = 'unfiltered';
            rSquareThresh = (r_square) > threshold;
            phase_at_0_screened = phase_at_0;
            phase_at_0_screened(~rSquareThresh) = nan;
            meanPhase = nanmean(phase_at_0_screened,1);
            weights = (desiredF)-rad2deg(meanPhase(chans));
            meanRsquares = mean(r_square(:,chans),1);
            markerSize = markerSizeFunc(markerMin,markerMax,min(meanRsquares),max(meanRsquares),meanRsquares);
            PlotDotsDirect(sid, locs(chans,:), weights, 'b',...
                [-max(abs(weights)) max(abs(weights))], markerSize,'america',[],false,false)
            plotObj = gcf;
            load('america'); % needs to be the same as what was used in the function call above
            colormap(cm);
            cbar = colorbar;
            cbar.Label.String = 'difference in degrees from desired frequency';
            PlotBrainJustDots(sid,{stims},[0 0 0],true);
            title({['Subject ' num2str(subjectNum) ' '  signalType ' signal stimulation delivery difference'],['from desired phase of ' num2str(desiredF) char(176) ]})
            
            
            objhl = findobj(plotObj, 'type', 'line'); % objects of legend of type patch
            
            leg = legend([objhl(end) objhl(end-1)],{['r^2 = ' num2str(min(mean(r_square(:,chans))))],['r^2 = ' num2str(max(mean(r_square(:,chans))))]});
            set(gca,'fontsize',14)
            %   objhl = findobj(objh, 'type', 'patch'); % objects of legend of type patch
            %set(objhl, 'Markersize', 12); % set marker size as desired
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if acausalPlot
            %%
            figure
            signalType = 'filtered';
            rSquareThresh_acaus = (r_square_acaus) > threshold;
            phase_at_0_screened = phase_at_0_acaus;
            phase_at_0_screened(~rSquareThresh_acaus) = nan;
            meanPhase = nanmean(phase_at_0_screened,1);
            weights = (desiredF)-rad2deg(meanPhase(chans));
            markerSize = markerSizeFunc(markerMin,markerMax,-1,1,mean(r_square_acaus(:,chans),1));
            PlotDotsDirect(sid, locs(chans,:), weights, 'b',...
                [-max(abs(weights)) max(abs(weights))], markerSize,'america',[],false,false)
            load('america'); % needs to be the same as what was used in the function call above
            colormap(cm);
            cbar = colorbar;
            cbar.Label.String = 'difference in degrees from desired frequency';
            PlotBrainJustDots(sid,{stims},[0 0 0],true);
            title({['Subject ' num2str(subjectNum) ' '  signalType ' signal stimulation delivery difference'],['from desired phase of ' num2str(desiredF) char(176) ]})
            
            
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end


