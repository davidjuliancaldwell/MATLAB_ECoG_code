function [] = ksdensity_plot(xVec,signal)

if isempty(xVec)
    xVec = [0:1:360];
end
%myfun = @(X) ksdensity(X,xVec,'bandwidth',45,'boundaryCorrection','reflection');
myfun = @(X) ksdensity(X,xVec,'support',[min(xVec) max(xVec)],'bandwidth',20,'boundaryCorrection','reflection');

pdfestimate = myfun(signal);
avgPlot = plot(xVec,pdfestimate,'k','linewidth',4);
legend([avgPlot],{'kernel density estimate'})
set(gca,'fontsize',14)

end