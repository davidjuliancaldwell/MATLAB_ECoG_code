%% PiDay_PlotCCEPSAmath
% This is to plot some CCEPs for the AMATH 582 poster session 

% uses rgb.m function from matlab file exchange 
ccolor = rgb('DarkMagenta');

% stim pulse
figure
average = 1e6*mean(kwins(:,klabel==0),2);
plot(1e3*t,1e6*kwins(:,klabel==0),'Linewidth',[2])
hold on
xlim(1e3*[-0.005 0.02])

xlabel('Time (ms)')
ylabel('Amplitude (\muV)')
set(gca,'Fontsize',[14]);
title('Stimulation Pulse')

hold off


figure
average = 1e6*mean(kwins(:,klabel==0),2);
plot(1e3*t,1e6*kwins(:,klabel==0),'Linewidth',[1])
hold on
plot(1e3*t,average,'Linewidth',[6],'color','k')
xlim(1e3*[-0.005 0.08])
ylim([-120 100])

xlabel('Time (ms)')
ylabel('Amplitude (\muV)')
set(gca,'Fontsize',[14]);
title({'CCEP post stimulus','Individual and Average Responses'})

hold off

% pretty line
figure
prettyline(1e3*t,1e6*awins(:,baselines),label(baselines),ccolor)
xlim(1e3*[-0.01 0.08])
xlabel('Time (ms)')
ylabel('Amplitude (\muV)')
set(gca,'Fontsize',[14]);
title({'Average CCEP post stimulus','+/- Standard Error'})

ylim([-120 100])

