function PlotEpochMeans(epochs, powers)

newFileAt = find(epochs(:,4)==1);
fileLengths = diff([newFileAt;size(epochs,1)+1]);

hold on; 

idx = 1;
for dailyEpochs = newFileAt'
    dailyEpochs = dailyEpochs:dailyEpochs+fileLengths(idx) - 1;
    
    upEpochs = dailyEpochs(1) + find(epochs(dailyEpochs,7)==1) - 1;
    downEpochs = dailyEpochs(1) + find(epochs(dailyEpochs,7)==2) - 1;
    nullEpochs = dailyEpochs(1) + find(epochs(dailyEpochs,7)==0) - 1;
    
    meanUp = mean(powers(upEpochs));
    meanDown = mean(powers(downEpochs));
    meanNull = mean(powers(nullEpochs));
    
    plot([min(dailyEpochs) max(dailyEpochs)],[meanUp meanUp],'color','b','marker','none','linestyle','-','linewidth',2);
    plot([min(dailyEpochs) max(dailyEpochs)],[meanDown meanDown],'color','r','marker','none','linestyle','-','linewidth',2);
    plot([min(dailyEpochs) max(dailyEpochs)],[meanNull meanNull],'color','k','marker','none','linestyle',':','linewidth',1);
    
    idx = idx + 1;   
end

ylims = get(gca,'ylim');

newFileEpochs = find(epochs(:,4)==1);
newFileEpochs(1) = [];

for e = newFileEpochs
    plot([e e] - 0.5,ylims,'k--');
end

set(gca,'ylim',ylims);

hold off;

