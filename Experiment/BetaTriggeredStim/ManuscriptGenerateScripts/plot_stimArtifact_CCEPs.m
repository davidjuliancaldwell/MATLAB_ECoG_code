%% plotStim artifact and EPs
% This is to plot some EPs for the AMATH 582 poster session 
load('C:\Users\djcald.CSENETID\Data\Output\BetaTriggeredStim\example_702d24_chan5.mat')

% uses rgb.m function from matlab file exchange 
ccolor = rgb('DarkMagenta');

% choose klabel
labelChoice = 0;

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
title({'EP post stimulus','Individual and Average Responses'})

hold off

% pretty line
figure
prettyline(1e3*t,1e6*awins(:,baselines),label(baselines),ccolor)
xlim(1e3*[-0.01 0.05])
xlabel('Time (ms)')
ylabel('Amplitude (\muV)')
set(gca,'Fontsize',[14]);
title({'Average EP post stimulus','+/- Standard Error'})

ylim([-100 50])

%%

figure
subplot(1,2,1)

plot(1e3*t,4*1e6*kwins(:,klabel==labelChoice),'Linewidth',[2])
hold on
xlim(1e3*[-0.005 0.05])
ylabel('Amplitude (\muV)')
set(gca,'Fontsize',[14]);
title('Stimulation Pulse')
xlabel('Time (ms)')

subplot(1,2,2)

average = 4*1e6*mean(kwins(:,klabel==labelChoice),2);
plot(1e3*t,4*1e6*kwins(:,klabel==labelChoice),'Linewidth',[2])
hold on
plot(1e3*t,average,'Linewidth',[6],'color','k')
xlim(1e3*[-0.005 0.05])
ylim([-400 400])

xlabel('Time (ms)')
ylabel('Amplitude (\muV)')
set(gca,'Fontsize',[14]);
title({'CEP post stimulus','Individual and Average Responses'})
