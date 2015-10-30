%% 10-28-2015 - Plot Extraced  data from beta triggered stimulation files that may be of interest for Larry
%

%% Constants
Z_ConstantsLarryStimulation;
addpath ./experiment/BetaTriggeredStim/scripts/ %DJC edit 8/14/2015

%%
sid = input('enter subject ID ','s');

chans = [1:64]; % want to look at all channels, DJC 8-28-2015

type = input('RAW or BandNotch ?','s');

load(fullfile(META_DIR, [sid '_LarryStats' type '.mat']), 't','muCell','stdErrCell','kwinsTotal');

%% do a plot of all channels

figure

for i = chans
    mu = muCell{i};
    stdErr = stdErrCell{i};
    chan = i;
    subplot(8,8,i)
    
    plot(1e3*t, 1e6*mu);
    
    xlim(1e3*[min(t) max(t)]);
    %     yl = ylim;
    %     yl(1) = min(-10, max(yl(1),-120));
    %     yl(2) = max(10, min(yl(2),100));
    %     ylim(yl);
    hold on
    %     vline(0);
    %
    %     hold on
    %     plot(1e3*t, 1e6*(mu+stdErr))
    %     hold on
    %
    %     plot(1e3*t, 1e6*(mu-stdErr))
    title(sprintf('Chan %d', chan))
    %
    %     xlabel('time (ms)');
    %     ylabel('ECoG (uV)');
    %
    %     title(sprintf('CCEP, Channel %d', chan))
    
    
    
end

%% plot channel of interest

chanInt = input('whats your channel of interest? ');
mu = muCell{chanInt};

figure

plot(1e3*t,1e6*mu)

