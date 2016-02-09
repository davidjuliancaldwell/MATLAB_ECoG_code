%% beta stimulation phase locking value - 9-16-2015 - djc
% right now for subject 0b5a2e, modified by DJC 1-11-2016

close all;clear all;clc
cd 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Code\Experiment\BetaTriggeredStim'
Z_ConstantsPLV;
addpath .\scripts\ %DJC edit 7/17/2015
sid = '0b5a2e';
%% pre stim

load('D:\Output\BetaTriggeredStim\meta\0b5a2e_preStimRestDecimated')

BlckPre = Blck;

% bandpass the signal to the window of interest
sigPre = bandpass(Blck,12,25,fs,4);

clear Blck;
% calculate the plv
betaPlvPre = plv_revised(sigPre);
[betaPLVchanPre,betaPLVchanPreTrim] = PLVAnal(betaPlvPre);

% % make a heat map of the PLV values
% figure
% imagesc(betaPlvPre)
% colorbar
% title('PLV Values Pre resting state')
%
% betaPlvPre55 = betaPlvPre((1:55),55);
% betaPlvPre55 = horzcat(betaPlvPre55',(betaPlvPre(55,(56:end))));
%
% betaPlvPre56 = betaPlvPre((1:56),56);
% betaPlvPre56 = horzcat(betaPlvPre56',(betaPlvPre(56,(57:end))));
%
% betaPlvPre64 = betaPlvPre((1:64),64);
% betaPlvPre64 = horzcat(betaPlvPre64',(betaPlvPre(64,(65:end))));


%% post stim
load('D:\Output\BetaTriggeredStim\meta\0b5a2e_postStimRestDecimated')

BlckPost = Blck;
% bandpass the signal to the window of interest
sigPost = bandpass(Blck,12,25,fs,4);

clear Blck;
% calculate the plv
betaPlvPost = plv_revised(sigPost);
[betaPLVchanPost,betaPLVchanPostTrim] = PLVAnal(betaPlvPost);

%
% figure
% imagesc(betaPlvPost)
% colorbar
% title('PLV Values Post resting state')
%
% betaPlvPost55 = betaPlvPost((1:55),55);
% betaPlvPost55 = horzcat(betaPlvPost55',(betaPlvPost(55,(56:end))));
%
% betaPlvPost56 = betaPlvPost((1:56),56);
% betaPlvPost56 = horzcat(betaPlvPost56',(betaPlvPost(56,(57:end))));
%
% betaPlvPost64 = betaPlvPost((1:64),64);
% betaPlvPost64 = horzcat(betaPlvPost64',(betaPlvPost(64,(65:end))));


%% look at the differences between two states
[betaPLVdifs] = PLVAnalDifs(betaPLVchanPreTrim,betaPLVchanPostTrim);


%% difference between the two on channel 55
diffs = betaPlvPost55 - betaPlvPre55;
figure
bar(diffs)
title('PLV differences between post and pre rest states in relation to channel 55 (Beta Stim Channel)')
xlabel('Channel Number')
ylabel('PLV value Difference')

%% channels of interest around 55 (which is the beta recording channel)
chansInt = [48,39,47,55,63,62,54,46];
diffsInt = diffs(chansInt);

stimsInt = [56 64];
diffsStim = diffs(stimsInt);

%% plot it on the brain
% this is for ecb43e or 0b5a2
% do this before looking at beta power

%there appears to be no montage for this subject currently
Montage.Montage = 64;
Montage.MontageTokenized = {'Grid(1:64)'};
Montage.MontageString = Montage.MontageTokenized{:};
Montage.MontageTrodes = zeros(64, 3);
Montage.BadChannels = [];
Montage.Default = true;

% get electrode locations
locs = trodeLocsFromMontage(sid, Montage, false);

%% some more preprocessing if desired, NEED MONTAGE LOADED 

BlckPreCAR = ReferenceCAR(Montage.Montage,Montage.BadChannels,BlckPre);
BlckPostCAR = ReferenceCAR(Montage.Montage,Montage.BadChannels,BlckPost);

BlckPre = BlckPreCAR;
BlckPost = BlckPostCAR;

%% brain plot for diffs

%select the channels that are in the grid
diffs64 = diffs(1:64);

% now plot the weights on the subject specific brain. PlotDotsDirect has a
% bunch of input arguments
figure;

clims = [min(diffs64) max(diffs64)];
PlotDotsDirect(sid, ... % the subject on who's brain the electrodes will be drawn
    locs, ... % the location of the electrodes
    diffs64, ... % the weights to use for coloring
    'l', ... % the hemisphere of the brain to draw (can be 'l', 'r', or 'b')
    clims, ... % the color limits for the weights
    15, ... % the size of the dots, in points I believe
    'recon_colormap', ... % the colormap to use for dot coloration
    1:64, ... % labels for the electrodes, I think this can be a cell array
    true, ... % a boolean switch as to whether or not to draw the labels
    false); % a boolean switch as to whether or not to redraw the cortex, used for multiple
% calls to PlotDotsDirect where you don't want to keep
% re-drawing the brain over itself

% very often, after plotting the brain and dots, I add a colorbar for
% reference as to what the dot colors mean
load('recon_colormap'); % needs to be the same as what was used in the function call above
colormap(cm);
colorbar;
title('Map of Differences between Pre and Post stim resting state PLV values for Beta Triggered Channel')

%% pre
%select the channels that are in the grid
betaPlvPre55selected = betaPlvPre55(1:64);

% now plot the weights on the subject specific brain. PlotDotsDirect has a
% bunch of input arguments
figure;

clims = [min(betaPlvPre55selected) max(betaPlvPre55selected)];
PlotDotsDirect(sid, ... % the subject on who's brain the electrodes will be drawn
    locs, ... % the location of the electrodes
    betaPlvPre55selected, ... % the weights to use for coloring
    'l', ... % the hemisphere of the brain to draw (can be 'l', 'r', or 'b')
    clims, ... % the color limits for the weights
    15, ... % the size of the dots, in points I believe
    'recon_colormap', ... % the colormap to use for dot coloration
    1:64, ... % labels for the electrodes, I think this can be a cell array
    true, ... % a boolean switch as to whether or not to draw the labels
    false); % a boolean switch as to whether or not to redraw the cortex, used for multiple
% calls to PlotDotsDirect where you don't want to keep
% re-drawing the brain over itself

% very often, after plotting the brain and dots, I add a colorbar for
% reference as to what the dot colors mean
load('recon_colormap'); % needs to be the same as what was used in the function call above
colormap(cm);
colorbar;
title('Pre stim resting state PLV values for Beta Triggered Channel')


%% post

%select the channels that are in the grid
betaPlvPost55selected = betaPlvPost55(1:64);

% now plot the weights on the subject specific brain. PlotDotsDirect has a
% bunch of input arguments
figure;

clims = [min(betaPlvPost55selected) max(betaPlvPost55selected)];
PlotDotsDirect(sid, ... % the subject on who's brain the electrodes will be drawn
    locs, ... % the location of the electrodes
    betaPlvPost55selected, ... % the weights to use for coloring
    'l', ... % the hemisphere of the brain to draw (can be 'l', 'r', or 'b')
    clims, ... % the color limits for the weights
    15, ... % the size of the dots, in points I believe
    'recon_colormap', ... % the colormap to use for dot coloration
    1:64, ... % labels for the electrodes, I think this can be a cell array
    true, ... % a boolean switch as to whether or not to draw the labels
    false); % a boolean switch as to whether or not to redraw the cortex, used for multiple
% calls to PlotDotsDirect where you don't want to keep
% re-drawing the brain over itself


% very often, after plotting the brain and dots, I add a colorbar for
% reference as to what the dot colors mean
load('recon_colormap'); % needs to be the same as what was used in the function call above
colormap(cm);
colorbar;
title('Post stim resting state PLV values for Beta Triggered Channel')

%% wanting to look at power in beta band pre and post as well

% extract log beta power
logPreBeta = log(hilbAmp(BlckPre,[12 25],fs).^2);
logPostBeta = log(hilbAmp(BlckPost,[12 25],fs).^2);

% take mean power for all time points for each of the channels
meanPre = mean(logPreBeta,1);
meanPost = mean(logPostBeta,1);

% select the first 64 channels that we can visualize on the grid
meanPreSelect = meanPre(1:64);
meanPostSelect = meanPost(1:64);

% look at TOTAL brain beta
meanBrainPre = mean(meanPre);
meanBrainPost = mean(meanPost);

% no multiple comparisons here 
ptarg = 0.05;
[hBetaBrainT,pBetaBrainT,ciBrainT,statsBrainT] = ttest2(meanPre,meanPost,ptarg,'both','unequal',2);


[pBetaBrainR,hBetaBrainR,statsBrainR] = ranksum(meanPre,meanPost,'alpha',ptarg,'tail','both');


% try stats out

% bonferonni correction!?
numChans = 64;
ptarg = 0.05/numChans;

% try rank sum and ttest
[hBetaT,pBetaT,ciT,statsT] = ttest2(logPreBeta,logPostBeta,ptarg,'both','unequal',1);

for i = 1:size(logPreBeta,2)
    [pBetaR(i),hBetaR(i),statsR(i)] = ranksum(logPreBeta(:,i),logPostBeta(:,i),'alpha',ptarg,'tail','both');
end



%% bar graphs pre and post
figure
bar(meanPreSelect)
title('log Beta power Pre stimulation')
xlabel('Channel Number')
ylabel('log Beta power')

figure
bar(meanPostSelect)
title('log Beta power Post stimulation')
xlabel('Channel Number')
ylabel('log Beta power')

%% plot pre brain beta


% now plot the weights on the subject specific brain. PlotDotsDirect has a
% bunch of input arguments
figure;

clims = [min(meanPreSelect) max(meanPreSelect)];
PlotDotsDirect(sid, ... % the subject on who's brain the electrodes will be drawn
    locs, ... % the location of the electrodes
    meanPreSelect, ... % the weights to use for coloring
    'l', ... % the hemisphere of the brain to draw (can be 'l', 'r', or 'b')
    clims, ... % the color limits for the weights
    15, ... % the size of the dots, in points I believe
    'recon_colormap', ... % the colormap to use for dot coloration
    1:64, ... % labels for the electrodes, I think this can be a cell array
    true, ... % a boolean switch as to whether or not to draw the labels
    false); % a boolean switch as to whether or not to redraw the cortex, used for multiple
% calls to PlotDotsDirect where you don't want to keep
% re-drawing the brain over itself


% very often, after plotting the brain and dots, I add a colorbar for
% reference as to what the dot colors mean
load('recon_colormap'); % needs to be the same as what was used in the function call above
colormap(cm);
colorbar;
title('Pre stim resting state log Beta power')

%% plot post brain beta


% now plot the weights on the subject specific brain. PlotDotsDirect has a
% bunch of input arguments
figure;

clims = [min(meanPostSelect) max(meanPostSelect)];
PlotDotsDirect(sid, ... % the subject on who's brain the electrodes will be drawn
    locs, ... % the location of the electrodes
    meanPostSelect, ... % the weights to use for coloring
    'l', ... % the hemisphere of the brain to draw (can be 'l', 'r', or 'b')
    clims, ... % the color limits for the weights
    15, ... % the size of the dots, in points I believe
    'recon_colormap', ... % the colormap to use for dot coloration
    1:64, ... % labels for the electrodes, I think this can be a cell array
    true, ... % a boolean switch as to whether or not to draw the labels
    false); % a boolean switch as to whether or not to redraw the cortex, used for multiple
% calls to PlotDotsDirect where you don't want to keep
% re-drawing the brain over itself


% very often, after plotting the brain and dots, I add a colorbar for
% reference as to what the dot colors mean
load('recon_colormap'); % needs to be the same as what was used in the function call above
colormap(cm);
colorbar;
title('Post stim resting state log Beta power')

%% beta difference
betaDiffs = meanPostSelect - meanPreSelect;

figure
bar(betaDiffs)
title('Difference in log Beta power Pre and Post stimulation')
xlabel('Channel Number')
ylabel('Difference of log Beta power')

figure
clims = [min(betaDiffs) max(betaDiffs)];
PlotDotsDirect(sid, ... % the subject on who's brain the electrodes will be drawn
    locs, ... % the location of the electrodes
    betaDiffs, ... % the weights to use for coloring
    'l', ... % the hemisphere of the brain to draw (can be 'l', 'r', or 'b')
    clims, ... % the color limits for the weights
    15, ... % the size of the dots, in points I believe
    'recon_colormap', ... % the colormap to use for dot coloration
    1:64, ... % labels for the electrodes, I think this can be a cell array
    true, ... % a boolean switch as to whether or not to draw the labels
    false); % a boolean switch as to whether or not to redraw the cortex, used for multiple
% calls to PlotDotsDirect where you don't want to keep
% re-drawing the brain over itself


% very often, after plotting the brain and dots, I add a colorbar for
% reference as to what the dot colors mean
load('recon_colormap'); % needs to be the same as what was used in the function call above
colormap(cm);
colorbar;
title('Pre and Post state log Beta power differences')
