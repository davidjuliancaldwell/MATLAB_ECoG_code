%% plotStim artifact and EPs
% This is to plot some EPs for the AMATH 582 poster session
load('C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\example_702d24_chan5.mat')

% uses rgb.m function from matlab file exchange
ccolor = rgb('DarkMagenta');

% choose klabel
labelChoice = 0;
%%
% stim pulse
figure
average = 4*1e6*mean(kwins(:,klabel==labelChoice),2);
plot(1e3*t,4*1e6*kwins(:,klabel==labelChoice),'Linewidth',[2])
hold on
xlim(1e3*[-0.005 0.05])

xlabel('Time (ms)')
ylabel('Amplitude (\muV)')
set(gca,'Fontsize',[14]);
title('Stimulation Pulse')

hold off


figure
average = 4*1e6*mean(kwins(:,klabel==labelChoice),2);
plot(1e3*t,4*1e6*kwins(:,klabel==labelChoice),'Linewidth',[1])
hold on
plot(1e3*t,average,'Linewidth',[6],'color','k')
xlim(1e3*[-0.005 0.05])
ylim([-100 50])

xlabel('Time (ms)')
ylabel('Amplitude (\muV)')
set(gca,'Fontsize',[14]);
title({'CEP post stimulus','Individual and Average Responses'})

hold off

% pretty line
figure
prettyline(1e3*t,1e6*awins(:,baselines),label(baselines),ccolor)
xlim(1e3*[-0.01 0.05])
xlabel('Time (ms)')
ylabel('Amplitude (\muV)')
set(gca,'Fontsize',[14]);
title({'Average CEP post stimulus','+/- Standard Error'})

ylim([-100 50])

%%


fh = figure;
ah1 = axes('Parent',fh,'Units','normalized','Position',[0.15 0.3 0.8 0.6]);
ah2 = axes('Parent',fh,'Units','normalized','Position',[0.15 0.1 0.8 0.1]);
%
axes(ah1)

average = 4*1e6*mean(kwins(:,klabel==labelChoice),2);
plot(1e3*t,4*1e6*kwins(:,klabel==labelChoice),'color',[0.7 0.7 0.7],'linewidth',0.5)
hold on
plot(1e3*t,average,'Linewidth',[6],'color','k')
xlim(1e3*[-0.005 0.05])
ylim([-400 400])

[maxPeak1,locPeak1] = max(average(1e3*t>4 & 1e3*t<10));
[maxPeak2,locPeak2] = min(average(1e3*t>8 & 1e3*t<20));
tTemp1 = 1e3*t(1e3*t>4 & 1e3*t<10);
tTemp2 = 1e3*t(1e3*t>8 & 1e3*t<20);

v1 = vline(tTemp1(locPeak1),'b:','peak_1')
v2 = vline(tTemp2(locPeak2),'b:','peak_2')


numTrials = size(kwins(:,klabel==labelChoice),2);
text(20,200,['N = ' num2str(numTrials)],'fontsize',20)
set(gca,'fontsize',18)

ylabel('Amplitude (\muV)')
title({'CEP post stimulus','Individual and Average Responses'})

axes(ah2)
plot(1e3*t,mean(4*1e6*kwins(:,klabel==labelChoice),2),'Linewidth',[2],'color','k')
hold on
xlim(1e3*[-0.005 0.05])
ylim('auto')
ylabel('Amplitude (\muV)')
set(gca,'Fontsize',[14]);
title('Stimulation Pulse')
xlabel('Time (ms)')
set(gca,'fontsize',18)

