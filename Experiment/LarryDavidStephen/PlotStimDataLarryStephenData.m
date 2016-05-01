%% 4/21/2016
% This is a script to plot the stim waveforms and CCEPs from a file 

% first - load in the data you want 

uiimport 

%% Plot AVERAGE

figure

numChans = size(ECoGDataAverage,2);

for i = 1:numChans

    chan = i;
    subplot(8,8,i)
    
    plot(1e3*t, 1e6*ECoGDataAverage(:,i));
    
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


%% plot INDIVIDUAL
figure

numChans = size(ECoGDataAverage,2);

for i = 1:numChans

    chan = i;
    subplot(8,8,i)
    
    plot(1e3*t, 1e6*ECoGData(:,:,i));
    
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
 