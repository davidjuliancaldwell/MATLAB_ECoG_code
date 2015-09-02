%% 8/11/2014 - DJC 
% The purpose of this function is to on a subject by subject basis look at
% differences between when subject was performing motor imagery and
% not. Input is data table with potential electrodes of interest

function [hInterest,pInterest,tsInterest,electrodesInterest,hUpInterest, pUpInterest, tsUpInterest, electrodesTIDupInterest, hDownInterest, pDownInterest, tsDownInterest,electrodesTIDdownInterest, subjid,montage] = RJBupDown(dataTable)
%% load curated data from Miah 

fprintf('Select file of interest \n'); 
filepath = promptForBCI2000Recording;
load(filepath);

% change filepath in order to get right part of subjid, otherwise it
% returns RJB (very filepathsensitive!) 

filepathMod = strrep(filepath,'RJB_Inference\','');
subjid = extractSubjid(filepathMod);

% to account for 7ee6bc having a bad montage
if strcmp(subjid,'7ee6bc')
   
    load('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\RJB_Inference\7ee6bc_ud_motS001R01_montage.mat');
    montage = Montage;
    
end

%% break up into rest and feedback periods, take mean in the samples dimension

% only electrodes of interest are selected from prior analysis, and
% selected using dataTable structure that is provided 

electrodes = dataTable.interestElectrodes{subjid};

hg_rest = mean(epochs_hg(:,:,t<-preDur),3);
hg_feedback = mean(epochs_hg(:,:,t > 0.5 & t < fbDur),3);

% look at up down for target, rather than ress for each

hgRestUp = hg_rest(electrodes,tgts==1 & tgts==ress);
hgRestDown = hg_rest(electrodes,tgts==2 & tgts==ress);
hgFeedbackUp = hg_feedback(electrodes,tgts==1 & tgts==ress);
hgFeedbackDown = hg_feedback(electrodes,tgts==2 & tgts==ress);
%% do 2 sample t-test for observations across channels, left tailed, as we are looking for less than 

% bonferroni corrected - account for bad channels. Only considering
% channels here for electrodes that showed significant TID overall, 

numChans = length(electrodes);
ptarg = 0.05 / numChans;

% 'right' means mean of x (hg_rest) is greater than mean of y (hg_feedback)

% two sample t-test
[hUp, pUp, ~, tsUp] = ttest2(hgRestUp,hgFeedbackUp,ptarg,'both','unequal',2);
[hDown, pDown, ~, tsDown] = ttest2(hgRestDown,hgFeedbackDown,ptarg,'both','unequal',2);
[hRest, pRest, ~, tsRest] = ttest2(hgRestUp,hgRestDown,ptarg,'both','unequal',2);
[hFeedback, pFeedback, ~, tsFeedback] = ttest2(hgFeedbackUp,hgFeedbackDown,ptarg,'both','unequal',2);

%% now for TID

hgUpDiff = hgRestUp-hgFeedbackUp;
hgDownDiff = hgRestDown - hgFeedbackDown;
[hTID, pTID, ~, tsTID] = ttest2(hgUpDiff,hgDownDiff,ptarg,'both','unequal',2);

electrodesTID = find(hTID==1);
electrodesInterest = electrodes(electrodesTID);
hInterest = hTID(electrodesTID);
pInterest = pTID(electrodesTID);
tsInterest = tsTID.tstat(electrodesTID);

%% now for TID early late
halfwayTrialsUp = ceil(size(hgRestUp,2)/2);
halfwayTrialsDown = ceil(size(hgRestDown,2)/2);

hgUpDiffEarly = hgUpDiff(:,1:halfwayTrialsUp);
hgUpDiffLate = hgUpDiff(:,halfwayTrialsUp+1:end);
hgDownDiffEarly = hgDownDiff(:,1:halfwayTrialsDown);
hgDownDiffLate = hgDownDiff(:,halfwayTrialsDown+1:end);

[hTIDup,pTIDup,~,tsTIDup] = ttest2(hgUpDiffEarly,hgUpDiffLate,ptarg,'both','unequal',2);
[hTIDdown,pTIDdown,~,tsTIDdown] = ttest2(hgDownDiffEarly,hgDownDiffLate,ptarg,'both','unequal',2);

TIDupEarlyMean = mean(hgUpDiffEarly,2);
TIDdownEarlyMean = mean(hgDownDiffEarly,2);
TIDupLateMean = mean(hgUpDiffLate,2);
TIDdownLateMean = mean(hgDownDiffLate,2);

electrodesTIDup = find(hTIDup ==1);
electrodesTIDupInterest = electrodes(electrodesTIDup);
electrodesTIDdown = find(hTIDdown ==1);
electrodesTIDdownInterest = electrodes(electrodesTIDdown);

hUpInterest = hTIDup(electrodesTIDup);
pUpInterest = pTIDup(electrodesTIDup);
tsUpInterest = tsTIDup.tstat(electrodesTIDup);

hDownInterest = hTIDdown(electrodesTIDdown);
pDownInterest = pTIDdown(electrodesTIDdown);
tsDownInterest = tsTIDdown.tstat(electrodesTIDdown);
  %% plot Rest Up, target up, rest down, target down 

fig4 = figure;
hold on
dim = ceil(sqrt(numChans));


for eIdx = 1:numChans
    
     subplot(dim,dim,eIdx);
     hold all
     
     plot(hgRestUp(eIdx,:));
     plot(hgRestDown(eIdx,:));
     plot(hgFeedbackUp(eIdx,:));
     plot(hgFeedbackDown(eIdx,:));
     
     electrodeInterest = electrodes(eIdx);
     title(['Electrode : ' num2str(electrodeInterest)]);
   
     

end

mtit(fig4,subjid,'xoff',0,'yoff',0.025);
legend('Rest up','Rest down','Target up','Target Down');
 %% plot depth of TID for up and Down, all channels

fig = figure;
hold on
dim = ceil(sqrt(numChans));


for eIdx = 1:numChans
    
     subplot(dim,dim,eIdx);
     hold all
     plot(hgUpDiff(eIdx,:));
     plot(hgDownDiff(eIdx,:));
     electrodeInterest = electrodes(eIdx);
     title(['Electrode : ' num2str(electrodeInterest)]);
     vline(halfwayTrialsUp,'b');
     vline(halfwayTrialsDown, 'g');
     

end

mtit(fig,subjid,'xoff',0,'yoff',0.025);
legend('up','down');
%% plot depth of TID vs. trial for SIGNIFICANT ones

[index] = find(pTID<=ptarg);

fig2 = figure;
dimSig = ceil(sqrt(length(index)));


for eIdxSig = 1:length(index)
    
    subplot(dimSig,dimSig,eIdxSig);
    hold all
    plot(hgUpDiff(eIdxSig,:));
    plot(hgDownDiff(eIdxSig,:));
    electrodeInterestSig = electrodes(index(eIdxSig));
    title(['Electrode : ' num2str(electrodeInterestSig)]);
    vline(halfwayTrialsUp,'b');
    vline(halfwayTrialsDown, 'g');

end

mtit(fig2,subjid,'xoff',0,'yoff',0.025);
legend('up','down');

%% gaussian smooth 

hgUpDiffSmooth = GaussianSmooth(hgUpDiff',20)';
hgDownDiffSmooth = GaussianSmooth(hgDownDiff',20)';

fig3 = figure;

for eIdxSigSmooth = 1:length(index)
    
    subplot(dimSig,dimSig,eIdxSigSmooth);
    hold all
    plot(hgUpDiffSmooth(eIdxSigSmooth,:));
    plot(hgDownDiffSmooth(eIdxSigSmooth,:));
    electrodeInterestSigSmooth = electrodes(index(eIdxSigSmooth));
    title(['Electrode : ' num2str(electrodeInterestSigSmooth)]);
    vline(halfwayTrialsUp,'b');
    vline(halfwayTrialsDown, 'g');

end


mtit(fig3,subjid,'xoff',0,'yoff',0.025);
legend('up','down');

%% plot depth of TID vs. trial for SIGNIFICANT ones, up down, early late 

[index] = find(pTIDup<=ptarg | pTIDdown<=ptarg);

fig5 = figure;
dimSig = ceil(sqrt(length(index)));


for eIdxSig = 1:length(index)
    
    subplot(dimSig,dimSig,eIdxSig);
    hold all
    plot(hgUpDiff(eIdxSig,:));
    plot(hgDownDiff(eIdxSig,:));
    electrodeInterestSig = electrodes(index(eIdxSig));
    title(['Electrode : ' num2str(electrodeInterestSig)]);
    vline(halfwayTrialsUp,'b');
    vline(halfwayTrialsDown,'g');

end

mtit(fig5,subjid,'xoff',0,'yoff',0.025);
legend('up','down');
%% plot depth of TID vs. trial for SIGNIFICANT ones, up down , gaussian smoothed

[index] = find(pTIDup<=ptarg | pTIDdown<=ptarg);

fig6 = figure;
dimSig = ceil(sqrt(length(index)));


for eIdxSig = 1:length(index)
    subplot(dimSig,dimSig,eIdxSig);
    hold all
    plot(GaussianSmooth(hgUpDiff(eIdxSig,:)',10));
    plot(GaussianSmooth(hgDownDiff(eIdxSig,:)',10));
    electrodeInterestSig = electrodes(index(eIdxSig));
    title(['Electrode : ' num2str(electrodeInterestSig)]);
    vline(halfwayTrialsUp,'b');
    vline(halfwayTrialsDown,'g');

end

mtit(fig6,subjid,'xoff',0,'yoff',0.025);
legend('up','down');
end