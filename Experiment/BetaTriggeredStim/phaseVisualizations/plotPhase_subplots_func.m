function [] = plotPhase_subplots_func(t,fitline,f,phase,rSquare,threshold,desiredF,sid,subjectNum,chan,type,signalType,OUTPUT_DIR,saveIt)

subtractMean = 1;

figure
subplot(2,1,1)

fitlineTemp = fitline(:,rSquare>threshold,:);

if subtractMean
    fitlineMean = repmat(nanmean(fitlineTemp,1),size(fitlineTemp,1),1);
else
    fitlineMean = zeros(size(fitlineTemp));
end

fitlineTemp = fitlineTemp - fitlineMean;

plot(1e3*t,fitlineTemp)
hold on
plot(1e3*t,nanmean(fitlineTemp,2),'k','linewidth',4)

title({['Subject ' num2str(subjectNum) ' Phase ' num2str(desiredF) char(176) ' fitline sweeps'], ['Channel ' num2str(chan)]})
set(gca,'fontsize',14)
xlim([-50 0])

fprintf('mean r_square value = %0.4f \n',mean(rSquare));
fprintf('mean phase at stimulus = %1.4f \n',mean(phase));
fprintf(' mean frequency of fit curve = %2.1f \n',mean(f));
set(gca,'fontsize',14)
xlim([-50 0])

subplot(2,1,2)
plotBTLError(1e3*t,fitlineTemp,'CI');
xlabel('time before stimulation (ms)')
ylabel('\mu V')
title({[' fitline 95% confidence interval']})
set(gca,'fontsize',14)
xlim([-50 0])

if saveIt
    SaveFig(OUTPUT_DIR, sprintf(['fitline-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'svg');
    SaveFig(OUTPUT_DIR, sprintf(['fitline-phase-%d-sid-%s-chan-%d-type-%s-filt-%s'],desiredF,sid, chan,type,signalType), 'png','-r600');
end

end