function [] = plotPhase_subplots_func(t,fitline,f,phase,rSquare,threshold,desiredF,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt,fThresholdMin,fThresholdMax)

subtractMean = 1;

numGoodTrials = sum(rSquare>threshold & f<fThresholdMax & f>fThresholdMin);
numTotalTrials = length(f);

figure
subplot(2,1,1)

fitlineTemp = fitline(:,rSquare>threshold & f>fThresholdMin & f<fThresholdMax,:);

if subtractMean
    fitlineMean = repmat(nanmean(fitlineTemp,1),size(fitlineTemp,1),1);
else
    fitlineMean = zeros(size(fitlineTemp));
end

fitlineTemp = fitlineTemp - fitlineMean;

plot(1e3*t,fitlineTemp,'color',[0.7 0.7 0.7],'linewidth',0.5)
hold on
plot(1e3*t,nanmean(fitlineTemp,2),'k','linewidth',4)

text(-35,min(fitlineTemp(:)),['N = ' num2str(numGoodTrials) '/' num2str(numTotalTrials)])

if subjectNum ==8
    title({['Subject 7 Playback Phase ' num2str(desiredF) char(176) ' fitline sweeps'], ['Channel ' num2str(chan)]})
    
else
    title({['Subject ' num2str(subjectNum) ' Phase ' num2str(desiredF) char(176) ' fitline sweeps'], ['Channel ' num2str(chan)]})
    
end
set(gca,'fontsize',14)
xlim([-40 0])
ylabel('\mu V')

ylim([-max(abs(fitlineTemp(:)))-20 max(abs(fitlineTemp(:)))+20])

fprintf('mean r_square value = %0.4f \n',mean(rSquare));
fprintf('mean phase at stimulus = %1.4f \n',mean(phase));
fprintf(' mean frequency of fit curve = %2.1f \n',mean(f));
set(gca,'fontsize',14)

subplot(2,1,2)
plotBTLError(1e3*t,fitlineTemp,'CI');
xlabel('time before stimulation (ms)')
ylabel('\mu V')
title({[' fitline 95% confidence interval']})
set(gca,'fontsize',14)
xlim([-40 0])
ylim([-max(abs(nanmean(fitlineTemp,2)))-10 max(abs(nanmean(fitlineTemp,2)))+10])
ylim([-80 80])

if saveIt
    SaveFig(OUTPUT_DIR, sprintf(['fitline-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
    SaveFig(OUTPUT_DIR, sprintf(['fitline-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
end

end