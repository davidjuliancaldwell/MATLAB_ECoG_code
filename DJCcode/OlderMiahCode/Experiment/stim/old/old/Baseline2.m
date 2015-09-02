%% setup for ebffea, long single epoch
% epochs = [116935 10616935];
% channels = [37 38 39 45 46 47];
% fs = 1000;
% filename = 'D:\research\subjects\ebffea\stimdata\rereferenced_clinical_NNN_1000Hz.mat';

%% setup for 7ee6bc, long single epoch
epochs = [ 5000 12992358 ];
channels = [46 47 48a 54 55 56];
fs = 1000;
filename = 'D:\research\subjects\7ee6bc\data\D3\clinical\rereferenced_clinical_long_NNN_1000Hz.mat';

windowLengthInSeconds = 1;
windowShiftInSeconds = 1;

chanCount = length(channels);
windowCount = 0;
for c = 1:size(epochs,1)
    windowCount = windowCount + (epochs(c,2)-epochs(c,1))/(windowShiftInSeconds*fs);
end
totalCount = windowCount * chanCount;
counter = 1;

beta = [12 18];
gamma = [75 115];

betaAvs     = cell(size(epochs,1),1);
gammaAvs    = cell(size(epochs,1),1);
spikeRecord = cell(size(epochs,1),1);
spectra = cell(size(epochs,1),1);

% h = waitbar(0, 'starting');

for chan = channels
    fprintf('working on channel %d\n', chan);
    idx = find(channels == chan);
    
    % get data
    load(strrep(filename, 'NNN', num2str(chan)));
    channelData = notch(channelData, [60 120 180], fs, 4);
     
    for epochNum = 1:size(epochs,1)        
        data = channelData(epochs(epochNum,1):epochs(epochNum,2),:);
       
%         betaSig = HilbAmp(data, beta, fs);
        gammaSig = HilbAmp(data, gamma, fs);
       
        winStart = 1;
        winEnd = winStart + windowLengthInSeconds * fs - 1;
        winNum = 1;
       
        while(winEnd < length(data))
%             h = waitbar(min(1,counter/totalCount), h, sprintf('working on channel %d.\n', chan));
            
            score = abs([0; diff(zscore(data(winStart:winEnd))) ]);
            if (max(score) > 2)
                [peaks, locs] = findpeaks(score, 'minpeakheight', 2);
                spikeRecord{epochNum}(idx, winNum) = length(locs);
            else
                figure, plot(score); hold on;
                
% %                 plot(zscore(data(winStart:winEnd)), 'r');
                close;
%             else
%                 locs = [];
            end
           
%             for loc = locs
%                 start = max(loc - 5, 1);
%                 endd  = min(loc + 10, length(data));
%                 
% %                 gammaSig(winStart+start:winStart+endd) = repmat(mean(gammaSig((winStart+start-.5*fs):winStart+start)), endd-start+1,1)';
%                 if winStart+start-0.5*fs >= 1
%                     
%                     data(winStart+start:winStart+endd) = repmat(mean(data((winStart+start-.5*fs):winStart+start)), endd-start+1,1)';
%                 end
%             end
 
            [f, hz] = pwelch(data(winStart:winEnd), winEnd-winStart+1, floor((winEnd-winStart+1)/2), floor((winEnd-winStart+1)/2), fs);
            
%             spectra{epochNum}(idx, winNum,:) = log(f);
            
            betaAvs{epochNum}(idx, winNum)  = sum(log(f(hz >  beta(1) & hz <  beta(2)))) / length(hz >  beta(1) & hz <  beta(2));
            temp = sum(log(f(hz > gamma(1) & hz < gamma(2)))) / length(hz > gamma(1) & hz < gamma(2));            
            gammaAvs{epochNum}(idx, winNum) = temp;
            
%             if ( temp > 0.2 )
%                 locs
%                 figure, plot((data(winStart:winEnd) - mean(data(winStart:winEnd))) / max(abs(data(winStart:winEnd)-mean(data(winStart:winEnd))))); hold on;
%                 plot(score, 'r');
%                 close;
%             end
%             gammaAvs{epochNum}(idx, winNum) = sum(log(f(hz > gamma(1) & hz < gamma(2)))) / length(hz > gamma(1) & hz < gamma(2));            
            
%             betaAvs{epochNum}(idx, winNum) = mean(betaSig(winStart:winEnd));
%             gammaAvs{epochNum}(idx, winNum) = mean(gammaSig(winStart:winEnd));
%             spikeRecord{epochNum}(idx, winNum) = length(locs);
                        
            winNum = winNum + 1;
            winStart = winStart + windowShiftInSeconds * fs;
            winEnd   = winEnd   + windowShiftInSeconds * fs;
            counter = counter + 1;
        end        
    end
end

%%
% figure;
% plot(squeeze(mean(spectra{1},2))); hold on;
% plot(squeeze(mean(spectra{2},2)),'r');
% plot(squeeze(mean(spectra{3},2)),'g');
% legend('pre','during','post');
% 
% return;
% close(h);
%% display results

spikes = [];
gammas = [];
betas = [];

for c = 1:length(spikeRecord)
    spikes = [spikes spikeRecord{c}];
    gammas = [gammas gammaAvs{c}];
    betas  = [betas betaAvs{c}];
end

for c = 1:length(channels)
    fprintf('averages for channel %d: \n', channels(c));
    for d = 1:length(spikeRecord)
        fprintf('  gamma from epoch %d: %f\n', d, mean(gammaAvs{d}(c,:)));
    end
    fprintf('\n');
    for d = 1:length(spikeRecord)
        fprintf('  beta from epoch %d: %f\n', d, mean(betaAvs{d}(c,:)));
    end
end

for c = 1:length(channels)
    figure;

    ax(1) = subplot(311); 
%     foo = downsample(channelData,1000);
    
%     plot(foo(1:length(gammas)));
    dsData = downsample(channelData,10);
    t = (1:length(dsData))/fs*10;
plot(t,dsData);
    axis tight;
    for d = 1:size(epochs)
        highlight(gca, round(epochs(d,:)/1000), [], [0.9 0.9 0.9]);
    end
    
    ax(2) = subplot(312);
    plot(gammas(c,:), 'b.'); hold on;
    plot(find(spikes(c,:)>=1), gammas(c,(spikes(c,:)>=1)), 'r.'); 

    ylim = get(gca, 'YLim');
    idx = 0;
    for d = 1:size(epochs)-1
        idx = idx + length(gammaAvs{d});
        plot([idx idx], ylim, 'g');
    end
    
%     av = zeros(size(gammas(c,:)));
%     for d = 2:length(gammas(c,:))
%         start = max(1, d-25);
%         av(d) = sum(gammas(c,start:d)) / (d-start);
%     end
    temp = gammas(c,:);
    temp(spikes(c,:)>=1) = NaN;
    av = windowedAverage(temp', 25);
    
    plot(av, 'k', 'LineWidth', 2);
    
    hold off;
    ylabel('gamma');
    xlabel('av windows');
    maximize(gcf);
%     highlight(gca, [length(spikeRecord{1})+1 length(spikeRecord{1}) + length(spikeRecord{2})], [], [0.9 0.9 0.9]);
    axis tight;

    ax(3) = subplot(313);
    plot(betas(c,:), 'b.'); hold on;
    plot(find(spikes(c,:)>=1), betas(c, (spikes(c,:)>=1)), 'r.'); 

    ylim = get(gca, 'YLim');
    idx = 0;
    for d = 1:size(epochs)-1
        idx = idx + length(betaAvs{d});
        plot([idx idx], ylim, 'g');
    end
    
%     av = zeros(size(betas(c,:)));
%     for d = 2:length(betas(c,:))
%         start = max(1, d-25);
%         av(d) = sum(betas(c,start:d)) / (d-start);
%     end
    temp = betas(c,:);
    temp(spikes(c,:)>=1) = NaN;
    av = windowedAverage(temp', 25);

    plot(av, 'k', 'LineWidth', 2);

    hold off;
    ylabel('beta');
    xlabel('av windows');
    axis tight;
%     highlight(gca, [length(spikeRecord{1})+1 length(spikeRecord{1}) + length(spikeRecord{2})], [], [0.9 0.9 0.9]);

%     linkaxes(ax, 'x');
    mtit(sprintf('electrode %d', channels(c)));
    
%     SaveFig([pwd '\7ee6bc'], sprintf('electrode %d', channels(c)));
%     close;
end