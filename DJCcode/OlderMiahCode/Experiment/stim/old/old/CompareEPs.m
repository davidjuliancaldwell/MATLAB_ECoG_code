%% setup for 7ee6bc
roi = [ 7.15e6 8.99e6 ];
srcchannel = 55; % src channel must be within channels
channels = 1:64;
fs = 1000;
flip = true;
mph = 200; % ad units
mpd = 50; % samples    

filename = 'D:\research\subjects\7ee6bc\data\D3\clinical\rereferenced_clinical_long_NNN_1000Hz.mat';


%% collect data for all channels
idx = 1;

for channel = channels
    fname_temp = strrep(filename, 'NNN', num2str(channel));
    load(fname_temp);
    
    if (~exist('marker', 'var'))
        marker = true;
        data = zeros(length(channelData(roi(1):roi(2))), length(channels));
    end
    
    data(:,idx) = channelData(roi(1):roi(2));
    data(:,idx) = data(:,idx) - mean(data(:,idx));
    data(:,idx) = notch(data(:,idx), [60 120 180], fs, 4);
    
    if (flip == true)
        data(:,idx) = -1*data(:,idx);
    end
    
    if (channel == srcchannel)
        srcidx = idx;
    end

    idx = idx+1;    
end

clear channel idx marker;

%%

% look at EPs
[av, win, tav, twin] = triggeredAverage(data(:,srcidx), mph, mpd, data, mpd, mpd);
t = (-mpd:mpd)/fs;

dim = ceil(sqrt(length(channels)));
figure;

for idx = 1:length(channels)
    subplot(dim, dim, idx);
    
    plot(t,squeeze(win(:,idx,:)), 'r');

    hold on;
    plot(t, squeeze(av(:,idx)), 'b');

    title(sprintf('electrode %d', channels(idx)));
end

% average