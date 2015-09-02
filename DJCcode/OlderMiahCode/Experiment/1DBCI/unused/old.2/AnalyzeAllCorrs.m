%% load
load([myGetenv('matlab_devel_dir') '\Experiment\1DBCI\AllPower.m.cache\allcors.mat']);

%% gut check

hist(distances, 500);
title('electrode distance distribution');
xlabel('distance from control electrode (norm to c-c dist)');
ylabel('number of electrodes at this distance');


%% now to work

% first eliminate all the NaNs (ie bad channels)
badIdx = isnan(upCorrelations) & isnan(downCorrelations);
  % should be the same, but whatever
  
upCorrelations = upCorrelations(~badIdx);
downCorrelations = downCorrelations(~badIdx);
distances = distances(~badIdx);

fprintf('dropping %d electrodes for bad channel status\n', sum(badIdx))

% now find means and ses
up = 1;
down = 2;

uds = unique(distances);

mus = zeros(length(uds), 2);
ses = zeros(length(uds), 2);

for c = 1:length(uds)
    ud = uds(c);
    
    idxs = distances == ud;
    mus(c, up)   = mean(upCorrelations  (idxs));
    mus(c, down) = mean(downCorrelations(idxs));
    ses(c, up)   = std (upCorrelations  (idxs)) / sqrt(sum(idxs));
    ses(c, down) = std (downCorrelations(idxs)) / sqrt(sum(idxs));
end

% plot it all
figure;

errorbar(uds, mus(:, up), ses(:, up), 'r');
hold on;
errorbar(uds, mus(:, down), ses(:, down), 'b');
set(gca, 'XLim', [0 10]);
set(gca, 'YLim', [-0.4 0.4]);
plot(get(gca, 'XLim'), [0 0], 'k--');
legend('up targets', 'down targets');
xlabel('distance from control electrode (norm to c-c dist)');
ylabel('correlation');
title('correlation of power change in remote electrode with that of control electrode during learning');

%% let's show it on a brain, for some spatial reference

ctl = 36;
gDists = findGridDistances(ctl, 1:64);
gIdxs  = zeros(size(gDists));

for c = 1:length(uds)
    gIdxs(gDists == uds(c)) = c;        
end

load('recon_colormap');

figure;
PlotDots('26cb98', {'Grid'}, mus(gIdxs, up), 'both', [-1 1], 20, 'recon_colormap');
view(90,0);
colorbar;
colormap(cm);

title('mean correlation of power change in remote electrode with that of ctl trode across subjects - up');

figure;
PlotDots('26cb98', {'Grid'}, mus(gIdxs, down), 'both', [-1 1], 20, 'recon_colormap');
view(90,0);
colorbar;
colormap(cm);

title('mean correlation of power change in remote electrode with that of ctl trode across subjects - down');

