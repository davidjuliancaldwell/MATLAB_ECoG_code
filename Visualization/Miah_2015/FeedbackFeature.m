function FeedbackFeature(subject,targetFiles,controlModality)
% 
%%DEBUG ONLY
% TwoTargFiles = {...
% 'C:\Research\Cache\octb09\D2\octb09_ud_mot_t001\octb09_ud_mot_tS001R02.mat',...
% 'C:\Research\Cache\octb09\D2\octb09_ud_mot_t001\octb09_ud_mot_tS001R03.mat',...
% 'C:\Research\Cache\octb09\D3\octb09_ud_mot_t001\octb09_ud_mot_tS001R01.mat',...
% 'C:\Research\Cache\octb09\D3\octb09_ud_mot_t001\octb09_ud_mot_tS001R02.mat'...
% };
% targetFiles = TwoTargFiles;
% subject = 'octb09';
% target = subject;
% controlModality = 'overt';
% % 
% addpath ../analysis
% %%global vars
% 
% tc1 = 1;
% tc2 = 2;
% 
% %% load and process files based on stimuli
% 
% % 
epochs = Get1DEpochs(targetFiles);
cursorPosY = GetSmoothedCursorPos(targetFiles);

NumChannels = GetNumChannels(targetFiles);
NumStimTypes = length(unique([epochs(:).TargetCode]));

PercentCorrect = Percent1DCorrect(epochs);

MeanRawPower = GetMeanRawPowers(targetFiles, epochs,'all');
ControlChannel = GetControlChannel(targetFiles);

% PlotEpochPowers(epochs,MeanRawPower(:,ControlChannel));
% PlotEpochMeans(epochs,MeanRawPower(:,ControlChannel));

% if strcmp(subject,'octb09') == 1 && strcmp(controlModality,'overt') == 1
%     epochs(108,7) = 0;
%     epochs(108,8) = 0;
% end

%%

f = figure;
subplot(2,1,1);
PlotEpochPowers(epochs,MeanRawPower(:,ControlChannel));
hold on;
clear highSample lowSample
colors = {[0 0 1]; [1 0 0]};
gaussianKernelWidth = 200;
storedTraces = {};
for targetCode = [1 2]
    epochTargets = SelectEpochs(epochs,'TargetCode',targetCode);
    powers = MeanRawPower([epochTargets(:).IndexNumber],ControlChannel);
%     lowSample{:,1,targetCode} = find(epochs(:,7)==targetCode);
%     lowSample{:,2,targetCode} = MeanRawPower(epochs(:,7)==targetCode,ControlChannel);
    allValidSamples = SelectEpochs(epochs,'TargetCode','~= 0');
    xSamples = min([allValidSamples(:).IndexNumber]):0.1:max([allValidSamples(:).IndexNumber]);
    ySamples = interp1([epochTargets(:).IndexNumber],powers,xSamples,'linear','extrap');
    ySamples = GaussianSmooth(ySamples,gaussianKernelWidth);
% %     highSample{:,1,targetCode} = find(epochs(:,7)~=0, 1 ):0.1:find(epochs(:,7)~=0, 1, 'last' );
%     highSample{:,2,targetCode} = interp1(lowSample{:,1,targetCode},lowSample{:,2,targetCode},highSample{:,1,targetCode},'linear','extrap');
%     highSample{:,3,targetCode} = GaussianSmooth(highSample{:,2,targetCode},gaussianKernelWidth);
        
    plot(xSamples,ySamples,'color',colors{targetCode},'linestyle','-');
    windowedStd = WindowedStd(ySamples,300); 
    plot(xSamples,ySamples + windowedStd./2,'color',(colors{targetCode} + [2 2 2]) ./ 3);
    plot(xSamples,ySamples - windowedStd./2,'color',(colors{targetCode} + [2 2 2]) ./ 3);
    
    storedTraces{targetCode,1} = xSamples;
    storedTraces{targetCode,2} = ySamples;
end
set(gca,'xlim',[0 size(epochs,2)]);

subplot(2,1,2);
hold on;
plot(storedTraces{1,1},storedTraces{1,2} - storedTraces{2,2});
xWidth = get(gca,'xlim');
plot(xWidth, [0 0],'k--');
set(gca,'xlim',[0 size(epochs,2)]);
DensePlot(2,1);

suptitle(sprintf('%s - %s', subject, controlModality));

set(gcf,'units','normalized')
set(gcf,'position',[0 0.25 0.75 0.75]);
set(gcf,'units','pixels')
set(gcf,'PaperPositionMode','auto')

SaveFig(['Learning\'],[ subject ' control electrode ' sprintf('%i',ControlChannel) ', ' controlModality]);

close(f);
%%

f = figure;
bar(PercentCorrect*100,'c'); 
set(gca,'ylim',[0 100]); 
hold on; 
plot([0 length(PercentCorrect)]+0.5,[50 50],'k--');
numFiles = unique([epochs(:).FileNumber]);
errorBars = zeros(length(numFiles),2);
for fNumIdx=numFiles
    fileEpochs = SelectEpochs(epochs,'FileNumber',fNumIdx);
    correct = [fileEpochs(:).TargetCode] == [fileEpochs(:).ResultCode];
    ci = bootci(10000,{@mean,correct},'alpha',.05)*100;
    errorBars(fNumIdx,:) = ci;
end
errorBars = (errorBars(:,2)-errorBars(:,1)) / 2;
errorbar(PercentCorrect*100,errorBars,'linestyle','none','color','k');

xlabel('Run number');
ylabel('Accuracy (%)');
title(sprintf('%s - %s',subject, controlModality));

SaveFig(['Learning\'],[ subject ' accuracy - ' controlModality]);

close(f);

%%
feedbackCursorPos = {};
for epoch=epochs
    feedbackCursorPos{epoch.IndexNumber} = cursorPosY(epoch.AbsoluteFeedbackBegin:epoch.AbsoluteFeedbackEnd,1);
end

% Position Plots
fileNums = unique([epochs(:).FileNumber]);
for i=fileNums
    f = figure;
    colors = 'br';
    for tc = 1:2
        
        fileEpochs = SelectEpochs(epochs,'FileNumber',i,'TargetCode',tc);
        hold on;
        for epoch = fileEpochs
            plot(feedbackCursorPos{epoch.IndexNumber},[colors(tc) '-']);
        end
    end
    title(sprintf('%s (Position) - %s %i',subject,controlModality,i));
    SaveFig(['Learning\'],sprintf('%s Traces (Position) - %s %i',subject,controlModality,i));
    close(f);
end

% Derivative Plots
fileNums = unique([epochs(:).FileNumber]);
for i=fileNums
    f = figure;
    colors = 'br';
    for tc = 1:2
        
        fileEpochs = SelectEpochs(epochs,'FileNumber',i,'TargetCode',tc);
        hold on;
        for epoch = fileEpochs
            plot(diff(feedbackCursorPos{epoch.IndexNumber}),[colors(tc) '-']);
        end
    end
    set(gca,'ylim',[-1 1]);
    title(sprintf('%s (Derivative) - %s %i',subject,controlModality,i));
    SaveFig(['Learning\'],sprintf('%s Traces (Derivative) - %s %i',subject,controlModality,i));
    close(f);
end

numComponents = 8;
% PCA on positions
f = figure;

ControlEpochs = SelectEpochs(epochs,'TargetCode','~= 0');
controlCursorPos = [];
idx = 1;
for epoch = ControlEpochs
    cYPos = feedbackCursorPos{epoch.IndexNumber};
    if idx == 1
        controlCursorPos(:,idx) = cYPos;
    else
        controlCursorPos(:,idx) = cYPos(1:size(controlCursorPos,1));
    end
    idx = idx + 1;
end
[vecs vals] = eigs(controlCursorPos*controlCursorPos', numComponents); 

vals = cumsum(vals);
vals = vals(numComponents,:);

eigOut = (vecs'*controlCursorPos);
plot(vecs);
suptitle(sprintf('%s - PCA Components (Position) %s',subject,controlModality));
legend('1','2','3','4','5','6');
SaveFig(['Learning\'],sprintf('%s PCA - %s',subject,controlModality));
close(f);

f = figure; 
for pc = 1:numComponents 
    subplot(4,2,pc);
    ControlEpochs = SelectEpochs(epochs,'TargetCode','~= 0');
    upEpochs = ControlEpochs([ControlEpochs(:).TargetCode]==1);
    downEpochs = ControlEpochs([ControlEpochs(:).TargetCode]==2);
    plot([upEpochs(:).IndexNumber], eigOut(pc,[ControlEpochs(:).TargetCode]==1),'b.'); 
    hold on; 
    plot([downEpochs(:).IndexNumber], eigOut(pc,[ControlEpochs(:).TargetCode]==2),'r.');
end
DensePlot(4,2);
suptitle(sprintf('%s - PCA Projection (Position) %s',subject,controlModality));
SaveFig(['Learning\'],sprintf('%s - PCA Projection (Position) %s',subject,controlModality));
close(f);
%%
% PCA on derivative
f = figure;

ControlEpochs = SelectEpochs(epochs,'TargetCode','~= 0');
controlCursorPos = [];
idx = 1;
for epoch = ControlEpochs
    cYPos = feedbackCursorPos{epoch.IndexNumber};
    if idx == 1
        controlCursorPos(:,idx) = cYPos;
    else
        controlCursorPos(:,idx) = cYPos(1:size(controlCursorPos,1));
    end
    idx = idx + 1;
end
dControlCursorPos = diff(controlCursorPos,1);
[vecs vals] = eigs(dControlCursorPos*dControlCursorPos', numComponents); 

vals = cumsum(vals);
vals = vals(numComponents,:);

eigOut = (vecs'*dControlCursorPos);
plot(vecs);
suptitle(sprintf('%s - PCA Components (derivative) %s',subject,controlModality));
legend('1','2','3','4','5','6');
set(gca,'ylim',[-.2 .2]);
SaveFig(['Learning\'],sprintf('%s PCA (derivative) - %s',subject,controlModality));
close(f);
%%
f = figure; 
for pc = 1:numComponents 
    subplot(4,2,pc);
    ControlEpochs = SelectEpochs(epochs,'TargetCode','~= 0');
    upEpochs = ControlEpochs([ControlEpochs(:).TargetCode]==1);
    downEpochs = ControlEpochs([ControlEpochs(:).TargetCode]==2);
    plot([upEpochs(:).IndexNumber], eigOut(pc,[ControlEpochs(:).TargetCode]==1),'b.'); 
    hold on; 
    plot([downEpochs(:).IndexNumber], eigOut(pc,[ControlEpochs(:).TargetCode]==2),'r.');
end
DensePlot(4,2);
suptitle(sprintf('%s - PCA Projection (derivative) %s',subject,controlModality));
SaveFig(['Learning\'],sprintf('%s - PCA Projection (derivative) %s',subject,controlModality));
close(f);

return

%concatentate each file
% for file = targetFiles
%     file = file{:};
%     load(file,'gStates','gParams','BadChannels');       % raw file
%     load([file(1:end-4) '_bphp.mat']);                  % chi range
%     load([file(1:end-4) '_opts.mat']);                  % chi range
%     numTargs = gParams.NumberTargets;
%     
%     % correct cursor position for 0,0 to be lower left corner
%     if ismember(fields(gStates),'CursorPosY')
%         cpy = CorrectCursorPosition(gStates.CursorPosY, gStates.WindowHeight);
%     end
% 
%     % segment data based on epochs
%     
%     
%     
%     epochsTemp = IdentifyEpochs(Condition, EpochVars);
%     epochs = [epochs;epochsTemp];
%     eLens = [eLens size(epochsTemp,1)];
%     
%     % determine the number of unique epoch types there are (including rest, 0) and set up the strings for images
%     
%     StimNumeric = unique(epochs(:,3));
%     StimTemp = StimNumeric;
%     StimTemp(StimTemp == 0) = [];
%     % StimString = gParams.Stimuli(1,StimTemp);
%     % StimString = gParams.Matrix(1,StimTemp);
%     % StimString = {'Rest','Top','Middle','Botom'};
%     
%     % accounting and correct percentages
%     NumChannels = size(PowerOut,2);
%     NumEpochs = size(epochs,1);
%     numZeros = length(find(epochsTemp(:,3)==0));
%     pctCorrect = (length(find(epochsTemp(:,3)==epochsTemp(:,4)))-numZeros) / (length(epochsTemp)-numZeros);
%     fprintf('Percent Correct: %02.2f%%\n', pctCorrect*100);
% 
%     if isempty(SumPowers)
%         SumPowers = zeros([size(PowerOut,2) 0] + [0 eLens(end)]);
%     else
%         temp = zeros([size(SumPowers,1) 0] + [0 sum(eLens)]);
%         temp(:,1:size(SumPowers,2)) = SumPowers;
%         SumPowers = temp;
%     end
%     
%     if ismember(fields(gStates),'CursorPosY')
%         % hardcoded to epoch length of 3040!
%         if isempty(targetPos)
%             targetPos = zeros(3040,eLens);
%         else
%             temp = zeros(3040,sum(eLens));
%             temp(:,1:size(targetPos,2)) = targetPos;
%             targetPos = temp;
%         end
%     end
%     
%     %calculate the mean power for each epoch
%     for epoch = epochsTemp'
%         if ismember(fields(gStates),'CursorPosY')
%             targetPos(:,eidx) = cpy(epoch(1)+2001:epoch(1)+5040);
%         end
%         for Channel = 1:NumChannels
%             MeanPowers(Channel, eidx) = mean(log(PowerOut(epoch(1):epoch(2), Channel)));
%         end
%         eidx = eidx + 1;
%     end
% end
% 
% if sum(ismember(fields(gParams),'Classifier')) > 0
%     %Tim's RJB version
%     controlChannel = gParams.TransmitChList(str2double(gParams.Classifier{1,1}));
% else
%     %Kai's UD version
%     controlChannel = gParams.TransmitChList(str2double(gParams.MUD{1,1}));
% end
% 
% 
% %% raw epoch power dots
% offset = 0;
% 
% f = figure;
% hold on;
% 
% for elen = eLens
%      runRange = offset+1:(offset+elen);
%      upE = offset + find(epochs(runRange,3) == tc1);
%      upEHit = epochs(runRange,3) == tc1 & epochs(runRange,3)==epochs(runRange,4);
%      upEMiss = epochs(runRange,3) == tc1 & epochs(runRange,3)~=epochs(runRange,4);
%  
%      downE = offset + find(epochs(runRange,3) == tc2);
%      downEHit = epochs(runRange,2) == tc2 & epochs(runRange,3)==epochs(runRange,4);
%      downEMiss = epochs(runRange,2) == tc2 & epochs(runRange,3)~=epochs(runRange,4);
%  
%      upPwrs = MeanPowers(controlChannel,upE);
%      downPwrs = MeanPowers(controlChannel,downE);
%      plot(upE,upPwrs,'r.');
%      plot(downE,downPwrs,'b.');
%      offset = offset + elen;
% end
%  
% offset = 0;
% for elen = eLens
%     offset = offset + elen;
%     plot([offset offset] + 0.5,get(gca,'ylim'),'k--');
% end
% 
% plot(find(epochs(:,4)~=epochs(:,3)),MeanPowers(controlChannel,epochs(:,4)~=epochs(:,3)),'color','k','marker','x','markersize',10,'linestyle','none');
% 
% set(gca,'xlim',[0 sum(eLens)]);
% 
% SaveFigs(target,'FeedbackFeature','Control Feature, mean power during epochs');
% 
% close(f);
% 
% %% cortical plots of RSA for each epoch 
% 
% % UNDO THIS THIS SHOULDNT BE HERE
% % should be in the multitarg
% 
% %todo: should be in z-scores
% 
% load(['C:\Research\Data\Patients\' subject '\trodes.mat'])
% load(['C:\Research\Data\Patients\' subject '\surf\' subject '_cortex.mat']);
% 
% 
% 
% idx = 1;    
% offset = 0;
% elen = sum(eLens);
% for elen = eLens
%     weights = zeros(size(MeanPowers,1),1);
%     runRange = offset+1:(offset+elen);
%     
%     for tc1=1:max(unique(epochs(runRange,3)))
%         for tc2=tc1+1:max(unique(epochs(runRange,3)))
%             for chan = 1:size(MeanPowers,1)
% 
% 
%                 upE = offset + find(epochs(runRange,3) == tc1);
%                 downE = offset + find(epochs(runRange,3) == tc2);
% 
%                 upPwrs = MeanPowers(chan,upE);
%                 downPwrs = MeanPowers(chan,downE);
% 
%         %         fprintf('Kurtosis: Up=%2.4f, Down=%2.4f\n',kurtosis(upPwrs),kurtosis(downPwrs));
% 
%                 weights(chan) = RSqActivation(upPwrs,downPwrs);
% 
% 
%             end
%             
% 
%             weights(BadChannels) = 0;
%             ctmr_gauss_plot(cortex,Options.MontageTrodes,weights,'l',[-.8 .8]);
%             SaveFigs(target,'FeedbackFeature',sprintf('(L) Cortical actiation run %02i - %i vs %i',idx, tc1, tc2));
%             close
% 
%             weights(BadChannels) = 0;
%             ctmr_gauss_plot(cortex,Options.MontageTrodes,weights,'r',[-.8 .8]);
%             SaveFigs(target,'FeedbackFeature',sprintf('(R) Cortical actiation run %02i - %i vs %i',idx, tc1, tc2));
%             close
%             
%             weights(BadChannels) = 0;
%             plot(weights);
%             hold on;
%             plot(weights,'r.');
%             ylim = get(gca,'ylim');
%             xlim = get(gca,'xlim');
%             offsetMont = 0;
%             for i=Options.Montage
%                 plot([i i]+offsetMont+0.5, ylim, 'linestyle','--','color','k');
%                 offsetMont = offsetMont + i;
%             end
%             set(gca,'xlim',[0 NumChannels]);
%             SaveFigs(target,'FeedbackFeature',sprintf('RSA run %02i - %i vs %i',idx, tc1, tc2));
%             close
%         end
%     end
%     
%     offset = offset + elen;
%     idx = idx + 1;
% end