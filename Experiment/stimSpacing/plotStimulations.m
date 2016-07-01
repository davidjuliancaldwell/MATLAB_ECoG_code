%% 6/24/2016 - Script to process human ECoG stim spacing data

% assumes data is loaded in
close all;clc;

cceps = input('want to look at CCEPs? "yes" or "no"','s');
%%
figure

sub = 1;

for idx = 1:16
    subplot(4,4,sub)
    plot(t',mean(dataEpochedLow(:,idx,:),3))
    hold on
    plot(t',mean(dataEpochedMid(:,idx,:),3))
    plot(t',mean(dataEpochedHigh(:,idx,:),3))
    xlim([min(t) max(t)])
    sub = sub+1;
    title(['Chan ',num2str(idx)])
    if strcmp(cceps,'yes')
        ylim([-100e-6 100e-6])
        xlim([0 60])
    end
    
end

legend({'Low','Mid','High'})
xlabel('time (ms)')
ylabel('voltage')
%%
figure
sub = 1;

for idx = 17:32
    subplot(4,4,sub)
    plot(t',mean(dataEpochedLow(:,idx,:),3))
    hold on
    plot(t',mean(dataEpochedMid(:,idx,:),3))
    plot(t',mean(dataEpochedHigh(:,idx,:),3))
    xlim([min(t) max(t)])
    sub = sub+1;
    title(['Chan ',num2str(idx)])
    if strcmp(cceps,'yes')
        ylim([-100e-6 100e-6])
        xlim([0 60])
    end
end

legend({'Low','Mid','High'})
xlabel('time (ms)')
ylabel('voltage')
%%
figure
sub = 1;

for idx = 33:48
    subplot(4,4,sub)
    plot(t',mean(dataEpochedLow(:,idx,:),3))
    hold on
    plot(t',mean(dataEpochedMid(:,idx,:),3))
    plot(t',mean(dataEpochedHigh(:,idx,:),3))
    xlim([min(t) max(t)])
    sub = sub+1;
    title(['Chan ',num2str(idx)])
    if strcmp(cceps,'yes')
        ylim([-100e-6 100e-6])
        xlim([0 60])
    end
end

legend({'Low','Mid','High'})
xlabel('time (ms)')
ylabel('voltage')
%%
figure
sub = 1;

for idx = 49:64
    subplot(4,4,sub)
    plot(t',mean(dataEpochedLow(:,idx,:),3))
    hold on
    plot(t',mean(dataEpochedMid(:,idx,:),3))
    plot(t',mean(dataEpochedHigh(:,idx,:),3))
    xlim([min(t) max(t)])
    sub = sub+1;
    title(['Chan ',num2str(idx)])
    if strcmp(cceps,'yes')
        ylim([-100e-6 100e-6])
        xlim([0 60])
    end
end

legend({'Low','Mid','High'})
xlabel('time (ms)')
ylabel('voltage')
%%
figure
sub = 1;

for idx = 65:80
    subplot(4,4,sub)
    plot(t',mean(dataEpochedLow(:,idx,:),3))
    hold on
    plot(t',mean(dataEpochedMid(:,idx,:),3))
    plot(t',mean(dataEpochedHigh(:,idx,:),3))
    xlim([min(t) max(t)])
    sub = sub+1;
    title(['Chan ',num2str(idx)])
    if strcmp(cceps,'yes')
        ylim([-100e-6 100e-6])
        xlim([0 60])
    end
    
end

legend({'Low','Mid','High'})
xlabel('time (ms)')
ylabel('voltage')
%%