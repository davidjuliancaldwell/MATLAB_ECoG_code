function [] = ksdensity_plot(xVec,signal)

xVec = [0:0.1:360];
myfun = @(X) ksdensity(X,xVec);
pdfestimate = myfun(signal);
avgPlot = plot(xVec,pdfestimate,'k','linewidth',4);
legend([avgPlot],{'kernel density estimate'})
set(gca,'fontsize',14)

end