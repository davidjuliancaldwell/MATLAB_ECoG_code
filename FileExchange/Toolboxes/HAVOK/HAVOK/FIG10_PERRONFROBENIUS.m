% Copyright 2016, All Rights Reserved
% Code by Steven L. Brunton
clear all, close all, clc
figpath = './figures/';
addpath('./utils');

FIG01_LORENZ_GEN
% load('./DATA/FIG01_LORENZ.mat');
load('./DATA/LorenzData_grid.mat');
load('./DATA/LorenzData_ts.mat');
ModelName = 'Lorenz';

%% Part 8:  BURSTING PREDICTION
L = 1:length(V);
inds = V(L,r).^2>4.e-6;
L = L(inds);
startvals = [];
endvals = [];
start = 1683;
clear interval hits endval newhit
numhits = 100;
for k=1:numhits;
    k;
    startvals = [startvals; start];
    endmax = start+500;
    interval = start:endmax;
    hits = find(inds(interval));
    endval = start+hits(end);
    endvals = [endvals; endval];
    newhit = find(inds(endval+1:end));
    start = endval+newhit(1);
end
figure
subplot(1,2,1)
plot3(xdat(startvals(1),1),xdat(startvals(1),2),xdat(startvals(1),3),'r','LineWidth',1.5), hold on
plot3(xdat(endvals(1),1),xdat(endvals(1),2),xdat(endvals(1),3),'Color',[.25 .25 .25],'LineWidth',1.5)
inds = LorenzData(:,4)==1;
plot3(LorenzData(inds(1),1),LorenzData(inds(1),2),LorenzData(inds(1),3),'o','Color',[0 0 .5],'MarkerFaceColor',[.2 .8 .2]), hold on

for k=1:numhits
    plot3(xdat(startvals(k):endvals(k),1),xdat(startvals(k):endvals(k),2),xdat(startvals(k):endvals(k),3),'r','LineWidth',1.5), hold on
end
for k=1:numhits-1
    plot3(xdat(endvals(k):startvals(k+1),1),xdat(endvals(k):startvals(k+1),2),xdat(endvals(k):startvals(k+1),3),'Color',[.25 .25 .25],'LineWidth',1.5), hold on
end

subplot(1,2,2)
plot3(xdat(startvals(1),1),xdat(startvals(1),2),xdat(startvals(1),3),'r','LineWidth',1.5), hold on
plot3(xdat(endvals(1),1),xdat(endvals(1),2),xdat(endvals(1),3),'Color',[.25 .25 .25],'LineWidth',1.5)
inds = LorenzData(:,4)==2;
plot3(LorenzData(inds(1),1),LorenzData(inds(1),2),LorenzData(inds(1),3),'o','Color',[.2 0 .2],'MarkerFaceColor',[.5 0 .5])

for k=1:numhits
    plot3(xdat(startvals(k):endvals(k),1),xdat(startvals(k):endvals(k),2),xdat(startvals(k):endvals(k),3),'r','LineWidth',1.5), hold on
end
for k=1:numhits-1
    plot3(xdat(endvals(k):startvals(k+1),1),xdat(endvals(k):startvals(k+1),2),xdat(endvals(k):startvals(k+1),3),'Color',[.25 .25 .25],'LineWidth',1.5), hold on
end

subplot(1,2,1)
inds = LorenzData(:,4)==1;
plot3(LorenzData(inds,1),LorenzData(inds,2),LorenzData(inds,3),'o','Color',[0 0 .5],'MarkerFaceColor',[.2 .8 .2]), hold on
axis tight
set(gca,'FontSize',14)
view(34,22)
set(gcf,'Position',[100 100 600 400])
set(gcf,'PaperPositionMode','auto')
% legend('Nonlinear','Approximately Linear','Almost Invariant Set')
subplot(1,2,2)
inds = LorenzData(:,4)==2;
plot3(LorenzData(inds,1),LorenzData(inds,2),LorenzData(inds,3),'o','Color',[.2 0 .2],'MarkerFaceColor',[.5 0 .5])

axis tight
set(gca,'FontSize',14)
view(34,22)
set(gcf,'Position',[100 100 900 400])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_PERRONFROBENIUS.eps']);

%%
figure
plot3(xdat(startvals(1),1),xdat(startvals(1),2),xdat(startvals(1),3),'r','LineWidth',1.5), hold on
plot3(xdat(endvals(1),1),xdat(endvals(1),2),xdat(endvals(1),3),'Color',[.25 .25 .25],'LineWidth',1.5), hold on
inds = LorenzData(:,4)==1;
plot3(LorenzData(inds(1),1),LorenzData(inds(1),2),LorenzData(inds(1),3),'o','Color',[0 0 .5],'MarkerFaceColor',[.2 1 .2]), hold on
inds = LorenzData(:,4)==2;
k = find(inds==1);
plot3(LorenzData(inds(k(1)),1),LorenzData(inds(k(1)),2),LorenzData(inds(k(1)),3),'o','Color',[0 0.5 0],'MarkerFaceColor',[.2 0.2 1]), hold on

for k=1:numhits
    plot3(xdat(startvals(k):endvals(k),1),xdat(startvals(k):endvals(k),2),xdat(startvals(k):endvals(k),3),'r','LineWidth',1.5), hold on
end
for k=1:numhits-1
    plot3(xdat(endvals(k):startvals(k+1),1),xdat(endvals(k):startvals(k+1),2),xdat(endvals(k):startvals(k+1),3),'Color',[.25 .25 .25],'LineWidth',1.5), hold on
end
inds = LorenzData(:,4)==1;
plot3(LorenzData(inds,1),LorenzData(inds,2),LorenzData(inds,3),'o','Color',[0 0 .5],'MarkerFaceColor',[.2 1 .2]), hold on
inds = LorenzData(:,4)==2;
plot3(LorenzData(inds,1),LorenzData(inds,2),LorenzData(inds,3),'o','Color',[0 0.5 0],'MarkerFaceColor',[.2 .2 1])
axis tight
set(gca,'FontSize',14)
view(34,22)
set(gcf,'Position',[100 100 500 400])
set(gcf,'PaperPositionMode','auto')
legend('Nonlinear','Approximately Linear','Almost Invariant Set, A','Almost Invariant Set, B')
% print('-depsc2', '-loose', [figpath,ModelName,'_PERRONFROBENIUS_BIG.eps']);