function [boot,confBoot,pdfestimate] = density_bootstrap_plot(xVec,signal)

% based off mathworks website

opt = statset('UseParallel',true);

xVec = [0:0.1:360];
myfun = @(X) ksdensity(X,xVec);
pdfestimate = myfun(signal);
boot = bootstrp(500,myfun,signal,'Options',opt);
confBoot = bootci(500,{myfun,signal},'Options',opt);

figure
hold on
for i=1:size(boot,1)
    h(i) = plot(xVec,boot(i,:),'c:');
end
avgPlot = plot(xVec,pdfestimate,'k','linewidth',4);
%xlabel('x');ylabel('Density estimate')
%plot(xVec,confBoot(1,:),'b','linewidth',2)
%plot(xVec,confBoot(2,:),'b','linewidth',2)
set(gca,'fontsize',14)

legend([avgPlot h(1)],{'kernel density estimate','bootstrap resampling'})

end