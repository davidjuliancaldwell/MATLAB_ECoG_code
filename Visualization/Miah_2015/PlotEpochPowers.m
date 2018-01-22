function PlotEpochPowers(epochs, powers)

upEpochs = SelectEpochs(epochs,'TargetCode','==1');
downEpochs = SelectEpochs(epochs,'TargetCode','==2');
nullEpochs = SelectEpochs(epochs,'TargetCode','==0');
missedEpochs = epochs([epochs(:).TargetCode] ~= [epochs(:).ResultCode]);
hold on;

ylim('auto');

plot([upEpochs(:).IndexNumber],powers([upEpochs(:).IndexNumber]),'color','b','marker','.','linestyle','none','markersize',15);
plot([downEpochs(:).IndexNumber],powers([downEpochs(:).IndexNumber]),'color','r','marker','.','linestyle','none','markersize',15);
plot([missedEpochs(:).IndexNumber],powers([missedEpochs(:).IndexNumber]),'color',[1 1 1],'marker','.','linestyle','none','markersize',5);
%plot(nullEpochs,powers(nullEpochs),'color','k','marker','.','linestyle','none','markersize',3);



ylims = get(gca,'ylim');

newFileEpochs = SelectEpochs(epochs,'NewFile','==1');
newFileEpochs(1) = [];

for e = newFileEpochs
    plot([e.IndexNumber e.IndexNumber] - 0.5,ylims,'k--');
end

set(gca,'ylim',ylims);

hold off;

