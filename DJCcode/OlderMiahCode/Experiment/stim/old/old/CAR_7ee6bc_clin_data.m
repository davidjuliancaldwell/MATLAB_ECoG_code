%% CAR data
clear;
chans = 2:105;
% chans = 2:3;

edf = sdfopen('d:\research\subjects\7ee6bc\data\D3\clinical\day6.edf', 'r', chans);

tod.H = 18;
tod.M = 30;
tod.S = 0;

h = waitbar(0, 'working');
for chan = chans
    idx = find(chans == chan);
    waitbar(idx/length(chans), h);
    temp = getClinicalData('d:\research\subjects\7ee6bc\data\D3\clinical\day6.edf', tod, 6000, chan);
    
    if (idx == 1)
        data = zeros(ceil(length(temp)/2), length(chans));
    end
    
    data(:,idx) = downsample(temp,2);
end

fs = 1000;

done = zeros(length(data), 1);

step = 100000;
for t = 1:step:length(data)
    stop = min(length(data), t+step-1);
    done(t:stop) = done(t:stop) + 1;
    data(t:stop, :) = averageReference(data(t:stop, :));
end

for c = 1:size(data,2)
    channelData = data(:,c);
    save(strrep('d:\research\subjects\7ee6bc\data\D3\clinical\rereferenced_clinical_NNN_1000Hz.mat', 'NNN', num2str(c)), 'channelData', 'fs');
end
close(h);