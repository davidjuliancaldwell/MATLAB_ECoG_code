% Copyright 2016, All Rights Reserved
% Code by Steven L. Brunton
clear all, close all, clc

FIG01_LORENZ_GEN
% load('./DATA/FIG01_LORENZ.mat');
ModelName = 'Lorenz';

%%  Part 1: Attractor
figure
L = 1:200000;
plot3(xdat(L,1),xdat(L,2),xdat(L,3),'Color',[.1 .1 .1],'LineWidth',1.5)
axis on
view(-5,12)
axis tight
xlabel('x'), ylabel('y'), zlabel('z')
set(gca,'FontSize',14)
set(gcf,'Position',[100 100 600 400])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p1_axis.eps']);

%%  Part 2:  Time Series
figure
plot(tspan,xdat(:,1),'k','LineWidth',2)
xlabel('t'), ylabel('x')
set(gca,'XTick',[0 10 20 30 40 50 60 70 80 90 100],'YTick',[-20 -10 0 10 20])
set(gcf,'Position',[100 100 550 300])
xlim([0 100])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p2_axis.eps']);

%%  Part 3:  Embedded Attractor
figure
L = 1:170000;
plot3(V(L,1),V(L,2),V(L,3),'Color',[.1 .1 .1],'LineWidth',1.5)
axis tight
xlabel('v_1'), ylabel('v_2'), zlabel('v_3')
set(gca,'FontSize',14)
view(34,22)
set(gcf,'Position',[100 100 600 400])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p3_axis.eps']);

%%  Part 4:  Model Time Series
L = 300:25000;
L2 = 300:50:25000;
figure
subplot(2,1,1)
plot(tspan(L),x(L,1),'Color',[.4 .4 .4],'LineWidth',2.5)
hold on
plot(tspan(L2),y(L2,1),'.','Color',[0 0 .5],'LineWidth',5,'MarkerSize',15)
xlim([0 max(tspan(L))])
ylim([-.0051 .005])
ylabel('v_1')
box on
subplot(2,1,2)
plot(tspan(L),x(L,r),'Color',[.5 0 0],'LineWidth',1.5)
xlim([0 max(tspan(L))])
ylim([-.025 .024])
xlabel('t'), ylabel('v_{15}')
box on
set(gcf,'Position',[100 100 550 350])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p4_axis.eps']);

%%  Part 5:  Reconstructed Attractor
figure
L = 300:50000;
plot3(y(L,1),y(L,2),y(L,3),'Color',[0 0 .5],'LineWidth',1.5)
axis tight
xlabel('v_1'), ylabel('v_2'), zlabel('v_3')
set(gca,'FontSize',14)
view(34,22)
set(gcf,'Position',[100 100 600 400])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p5_axis.eps']);

%%  Part 6:  Forcing Statistics
figure
Vtest = std(V(:,r))*randn(200000,1);
[h,hc] = hist(V(:,r)-mean(V(:,r)),[-.03:.0025:.03]);%[-.03  -.02 -.015  -.0125 -.01:.0025:.01 .0125  .015 .02  .03]);
[hnormal,hnormalc] = hist(Vtest-mean(Vtest),[-.02:.0025:.02]);
semilogy(hnormalc,hnormal/sum(hnormal),'--','Color',[.2 .2 .2],'LineWidth',1.5)
hold on
semilogy(hc,h/sum(h),'Color',[0.5 0 0],'LineWidth',1.5)
xlabel('v_{15}')
ylabel('P(v_{15})')
ylim([.0001 1])
xlim([-.025 .025])
legend('Normal Distribution','Lorenz Forcing')
set(gcf,'Position',[100 100 550 300])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p6_axis.eps']);

%%  Part 7:  U Modes
figure
CC = [2 15 32;
    2 35 92;
    22 62 149;
    41 85 180;
    83 124 213;
    112 148 223;
    114 155 215];
for k=1:5
    plot(U(:,k),'linewidth',1.5+2*k/30,'Color',CC(k,:)/255), hold on
end
plot(U(:,6),'Color',[.5 .5 .5],'LineWidth',1.5)
plot(U(:,15),'linewidth',1.5,'Color',[0.75 0 0])
plot(U(:,1:r),'Color',[.5 .5 .5],'LineWidth',1.5)
plot(U(:,15),'linewidth',1.5,'Color',[0.75 0 0])
hold on
for k=5:-1:1
    plot(U(:,k),'linewidth',1.5+2*k/30,'Color',CC(k,:)/255)
end
xlabel('time index, k'), ylabel('u_r')
l1=legend('r=1','r=2','r=3','r=4','r=5','...','r=15');
set(l1,'location','NorthWest')
set(gcf,'Position',[100 100 550 300])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p7_axis.eps']);

%% Part 8:  PREDICTION OF LOBE SWITCHING

% compute indices where forcing is "active"
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
% Color code attractor by whether or not forcing is active
figure
for k=1:numhits
    plot3(V(startvals(k):endvals(k),1),V(startvals(k):endvals(k),2),V(startvals(k):endvals(k),3),'r','LineWidth',1.5), hold on
end
for k=1:numhits-1
    plot3(V(endvals(k):startvals(k+1),1),V(endvals(k):startvals(k+1),2),V(endvals(k):startvals(k+1),3),'Color',[.25 .25 .25],'LineWidth',1.5), hold on
end
axis tight
xlabel('v_1'), ylabel('v_2'), zlabel('v_3')
set(gca,'FontSize',14)
view(34,22)
set(gcf,'Position',[100 100 600 400])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p8_3Daxis.eps']);

%% Part 9:  PLOT PREDICTION AS TIME SERIES
figure
ax1=subplot(3,1,1)
plot(tspan(1:length(V)),V(:,1),'k'), hold on
for k=1:numhits
    plot(tspan(startvals(k):endvals(k)),V(startvals(k):endvals(k),1),'r','LineWidth',1.5), hold on
end
for k=1:numhits-1
    plot(tspan(endvals(k):startvals(k+1)),V(endvals(k):startvals(k+1),1),'Color',[.25 .25 .25],'LineWidth',1.5), hold on
end
ylabel('v_1')
ax2=subplot(3,1,2)
plot(tspan(1:length(V)),V(:,r),'k'), hold on
for k=1:numhits
    plot(tspan(startvals(k):endvals(k)),V(startvals(k):endvals(k),r),'r','LineWidth',1.5), hold on
end
for k=1:numhits-1
    plot(tspan(endvals(k):startvals(k+1)),V(endvals(k):startvals(k+1),r),'Color',[.25 .25 .25],'LineWidth',1.5), hold on
end
ylabel('v_{15}')
ax3=subplot(3,1,3)
plot(tspan(startvals(1)),V(startvals(1),r),'r'), hold on
plot(tspan(endvals(1)),V(startvals(2),r),'Color',[.25 .25 .25])
for k=1:numhits
    plot(tspan(startvals(k):endvals(k)),V(startvals(k):endvals(k),r).^2,'r','LineWidth',1.5), hold on
end
for k=1:numhits-1
    plot(tspan(endvals(k):startvals(k+1)),V(endvals(k):startvals(k+1),r).^2,'Color',[.25 .25 .25],'LineWidth',1.5), hold on
end
xlabel('t'), ylabel('v_{15}^2')
legend('Forcing Active','Forcing Inactive')
linkaxes([ax1,ax2,ax3],'x')
xlim([25 65])
set(gcf,'Position',[100 100 550 450])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p8_2Daxis.eps']);


%% PART 10:  TEST INTEGER MODEL
r=15;
A = zeros(14);
A = A+diag([-5 -10 -15 -20 25 -30 -35 -40 45 -50 -55 60 -65],1);
A = A+diag([5 10 15 20 -25 30 35 40 -45 50 55 -60 65],-1);
B = zeros(14,1);
B(end) = -70;
sysNew = ss(A,B,sys.c,sys.d);
[y,t] = lsim(sysNew,V(:,r),dt*(1:length(V)),V(1,1:r-1));
L = 1:199900;
plot(tspan(L),V(L,1),'k','LineWidth',2), hold on
plot(tspan(L),y(L,1),'r','LineWidth',2)
set(gcf,'Position',[100 100 550 300])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p9_axis.eps']);

%% PART 11: PLOT SKELETON OF LORENZ
k=27;
L0 = endvals(k-1):startvals(k);
plot(V(L0,1),V(L0,2),'Color',[.25 .25 .25],'LineWidth',1.5), hold on
L1 = startvals(k):endvals(k);
plot(V(L1,1),V(L1,2),'r','LineWidth',1.5)
L2 = endvals(k):startvals(k+1);
plot(V(L2,1),V(L2,2),'Color',[.25 .25 .25],'LineWidth',1.5)
L3 = startvals(k+1):startvals(k+1)+100;
plot(V(L3,1),V(L3,2),'r--','LineWidth',1.5)
L0 = endvals(k-1):10:startvals(k+1);
xlabel('v_1'), ylabel('v_2')
axis tight
set(gcf,'Position',[100 100 550 350])
set(gcf,'PaperPositionMode','auto')
% print('-depsc2', '-loose', [figpath,ModelName,'_p10_axis.eps']);