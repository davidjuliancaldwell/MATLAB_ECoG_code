%% function to be called for running analysis in early vs. late learning 
% DJC - 8/11/2014, assumes there is electrode information from overall
% analysis to sub select ones of interest 

function [ output_args ] = RJBearlyLateLearning(dataTable)

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

hgDiff = hg_rest - hg_feedback;
hgDiff = hgDiff(electrodes,:);

% Break up into early and late trials (divide down middle to start), select
% relevant electrodes using dataTable 

numTrials = size(hg_rest,2);
halfwayTrials = ceil(numTrials/2);

hgRestEarly = hg_rest(electrodes,1:halfwayTrials);
hgRestLate = hg_rest(electrodes,halfwayTrials+1:end);
hgFeedbackEarly = hg_feedback(electrodes,1:halfwayTrials);
hgFeedbackLate = hg_feedback(electrodes,halfwayTrials+1:end);

%% depth of modulation, subtraction of hgRestEarly-feedback, etc

hgEarlyDepth = hgRestEarly - hgFeedbackEarly;
hgLateDepth = hgRestLate - hgFeedbackLate;

hgEarlyDepthMean = mean(hgEarlyDepth,2);
hgLateDepthMean = mean(hgLateDepth,2);


%% do 2 sample t-test for observations across channels, left tailed, as we are looking for less than 

% bonferroni corrected - account for bad channels. Only considering
% channels here for electrodes that showed significant TID overall, 

numChans = length(electrodes);
ptarg = 0.05 / numChans;

% 'right' means mean of x (hg_rest) is greater than mean of y (hg_feedback) 

% two sample t-test
% [h, p, ~, ts] = ttest2(hgFeedbackEarly,hgFeedbackLate,ptarg,'both','unequal',2);
 [h, p, ~, ts] = ttest2(hgEarlyDepth,hgLateDepth,ptarg,'both','unequal',2);

%% plot depth of TID vs. trial, plot line for early vs late.

a = figure;
hold on
dim = ceil(sqrt(numChans));


for eIdx = 1:numChans
    
     subplot(dim,dim,eIdx);
     plot(hgDiff(eIdx,:));
     electrodeInterest = electrodes(eIdx);
     title(['Electrode : ' num2str(electrodeInterest)]);
     vline(halfwayTrials,'r');
     

end

mtit(a,subjid,'xoff',0,'yoff',0.025);
%% plot depth of TID vs. trial for SIGNIFICANT ones

[index] = find(p<=ptarg);

figure
hold on
dimSig = ceil(sqrt(length(index)));
hgDiffSig = hgDiff(index,:);

for eIdxSig = 1:length(index)
    
    subplot(dimSig,dimSig,eIdxSig);
    plot(hgDiffSig(eIdxSig,:));
    electrodeInterestSig = electrodes(index(eIdxSig));
    title(['Electrode : ' num2str(electrodeInterestSig)]);
    vline(halfwayTrials,'r');

end
%% gaussian smooth 

hgDiffSigSmooth = GaussianSmooth(hgDiffSig',25)';

figure
hold on

for eIdxSigSmooth = 1:length(index)
    
    subplot(dimSig,dimSig,eIdxSigSmooth);
    plot(hgDiffSigSmooth(eIdxSigSmooth,:));
    electrodeInterestSigSmooth = electrodes(index(eIdxSigSmooth));
    title(['Electrode : ' num2str(electrodeInterestSigSmooth)]);
    vline(halfwayTrials,'r');

end
%% get ready for large cortical plot 

end