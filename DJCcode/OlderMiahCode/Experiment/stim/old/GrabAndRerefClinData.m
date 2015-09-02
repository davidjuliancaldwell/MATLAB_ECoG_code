%% input variables

clear;
chans = 2:65;
filedir  = 'd:\research\subjects\ebffea';
filename = 'day7_part2.rec'
outputdir = 'd:\research\subjects\ebffea\stimdata';

tod.H = 16;
tod.M = 42;
tod.S = 0;

% work
for chan = chans
    fprintf('loading channel %d\n', chan);
    idx = find(chans == chan);

    temp = getClinicalData([filedir '\' filename], tod, 3600*3, chan);
    
    if (idx == 1)
        data = zeros(ceil(length(temp)/2), length(chans));
    end
    
    data(:,idx) = downsample(temp,2);
end

fs = 1000;

done = zeros(length(data), 1);

step = 100000;
for t = 1:step:length(data)
    fprintf('referencing %f complete\n', t/length(data));
    stop = min(length(data), t+step-1);
    done(t:stop) = done(t:stop) + 1;
    data(t:stop, :) = averageReference(data(t:stop, :));
end

for c = 1:size(data,2)
    fprintf('saving %d\n', c);
    channelData = data(:,c);
    save(sprintf('%s\\rereferenced_clinical_%s_1000Hz.mat', outputdir, num2str(c)), 'channelData', 'fs');
end
% close(h);

