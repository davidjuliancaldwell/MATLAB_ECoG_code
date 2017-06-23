% Copyright 2016, All Rights Reserved
% Code by Steven L. Brunton
clear all, close all, clc

FIG04_DUFFINGFORCED_GEN
% load('./DATA/FIG04_DUFFINGFORCED.mat');
ModelName = 'DuffingForced';

%%  Part 1: Attractor
L = 1:500000;
plot(xdat(L,1),xdat(L,2),'Color',[.1 .1 .1],'LineWidth',1.5)
set(gca,'XTick',[],'YTick',[],'ZTick',[])
axis tight
axis off
set(gcf,'Position',[100 100 3*250 3*175])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p1.eps']);

%%  Part 2:  Time Series
figure
tspan = dt:dt:dt*length(xdat);
plot(tspan,xdat(:,1),'k','LineWidth',2)
set(gca,'XTick',[0 10 20 30 40 50],'YTick',[-20 -10 0 10 20])
set(gcf,'Position',[100 100 2*250 2*175])
axis off
xlim([300 800])
% print('-depsc2', '-loose', [figpath,ModelName,'_p2.eps']);

%%  Part 3:  Embedded Attractor
figure
L = 1:90000;
plot3(V(L,1),V(L,2),V(L,3),'Color',[.1 .1 .1],'LineWidth',1.5)
set(gca,'XTick',[],'YTick',[],'ZTick',[])
axis tight
axis off
view(20,14)
set(gcf,'Position',[100 100 3*250 3*175])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p3.eps']);

%%  Part 4:  Model Time Series
xmin = 20000;
xmax = 90000;
L = xmin:xmax;
L2 = xmin:100:xmax;
figure
subplot(2,1,1)
plot(L,x(L,1),'Color',[.4 .4 .4],'LineWidth',2.5)
hold on
plot(L2,y(L2,1),'.','Color',[0 0 .5],'LineWidth',10,'MarkerSize',25)
xlim([xmin xmax])
box off, axis off
subplot(2,1,2)
plot(L,x(L,r),'Color',[.5 0 0],'LineWidth',1.5)
xlim([xmin xmax])
box off, axis off
set(gcf,'Position',[100 100 2*250 2*175])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p4.eps']);

%%  Part 5:  Reconstructed Attractor
figure
L = 1000:195000;
plot3(y(L,1),y(L,2),y(L,3),'Color',[0 0 .5],'LineWidth',1.5)
axis tight
axis off
view(20,14)
set(gcf,'Position',[100 100 3*250 3*175])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p5.eps']);

%%  Part 6:  Forcing Statistics
figure
Vtest = std(V(:,r))*randn(200000,1);
[h,hc] = hist(V(:,r)-mean(V(:,r)),[-.01:.001:.01]);%[-.03  -.02 -.015  -.0125 -.01:.0025:.01 .0125  .015 .02  .03]);
[hnormal,hnormalc] = hist(Vtest-mean(Vtest),[-.01:.001:.01])
semilogy(hnormalc,hnormal/sum(hnormal),'--','Color',[.2 .2 .2],'LineWidth',4)
hold on
semilogy(hc,h/sum(h),'Color',[0.5 0 0],'LineWidth',4)
ylim([.0001 1])
xlim([-.01 .01])
axis off
set(gcf,'Position',[100 100 2*250 2*175])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p6.eps']);

%%  Part 7:  U Modes
figure
CC = [2 15 32;
    2 35 92;
    22 62 149;
    41 85 180;
    83 124 213;
    112 148 223;
    114 155 215];
plot(U(:,1:r),'Color',[.5 .5 .5],'LineWidth',1.5)
hold on
for k=7:-1:1
    plot(U(:,k),'linewidth',1.5+2*k/10,'Color',CC(k,:)/255)
end
axis off
set(gcf,'Position',[100 100 2*250 2*175])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p7.eps']);


%% PART 8: PREDICT LOBE SWITCHING
L = 1:length(V);
inds = V(L,r).^2>1.e-5;
L = L(inds);
startvals = [];
endvals = [];
start = 149;
clear interval hits endval newhit
numhits = 295;
for k=1:numhits;
    k;
    startvals = [startvals; start];
    endmax = start+1000;
    interval = start:endmax;
    hits = find(inds(interval));
    endval = start+hits(end);
    endvals = [endvals; endval];
    newhit = find(inds(endval+1:end));
    start = endval+newhit(1);
end
%
figure
for k=1:numhits
    plot3(V(startvals(k):endvals(k),1),V(startvals(k):endvals(k),2),V(startvals(k):endvals(k),3),'r','LineWidth',1.5), hold on
end
for k=1:numhits-1
    plot3(V(endvals(k):startvals(k+1),1),V(endvals(k):startvals(k+1),2),V(endvals(k):startvals(k+1),3),'Color',[.25 .25 .25],'LineWidth',1.5), hold on
end
axis tight
axis off
view(20,14)
set(gcf,'Position',[100 100 3*250 3*175])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p8_3D.eps']);