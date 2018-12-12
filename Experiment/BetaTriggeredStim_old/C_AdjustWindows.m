%% Constants
Z_Constants;
addpath ./scripts;

%% parameters

% need to be fixed to be nonspecific to subject

sid = SIDS{1};

% sid = SIDS{2};

% sid = SIDS{3};

%% load in the trigger data
load(fullfile(META_DIR, sid, 'all'), 't', 'awins', 'efs', 'probes', 'pres', 'pairs', 'posts', 'chans', 'bads', 'stims', 'src');

bads = false(64, 1);

if (strcmp(sid, 'd5cd55'))
    bads([54 62]) = true;
elseif (strcmp(sid, 'c91479'))
    bads = [1 55 56];
elseif (strcmp(sid, '7dbdec'))
    bads = [11 12 8 57];
end
    


load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts');

%%

%% here's your chance to rereference
rwins = reshape(awins, size(awins, 1), size(awins, 2) * size(awins, 3));
mu = mean(rwins, 1);
rwins = bsxfun(@minus, rwins, mu);
rwins = reshape(rwins, [size(awins, 1), size(awins, 2), size(awins, 3)]);

%% and let's adjust the stimuli (detrend, etc)
fprintf('adjusting stimuli');
for chan = 1%1:size(rwins, 1)
    fprintf('.');
    rwins(chan, :, :) = adjustStims(squeeze(rwins(chan, :, :)));
end
fprintf('\n');

%% first, perform PCA on all windows:
muwins = squeeze(mean(rwins, 3));

[proj, filt, vfrac] = mpca(muwins(~bads, :)');

newfilt = zeros(64, 64);
newfilt(~bads, ~bads) = filt;

newproj = zeros(length(t), 64);
newproj(:, ~bads) = proj;

toremove = newfilt(:,1:3) * newproj(:, 1:3)';

rwins = bsxfun(@minus, rwins, toremove);
% rwins(:,1:180,:) = 0;

%% now, just as a test, let's compare pres and posts

label = bursts(4,pairs(3,:));
colors = interp1(1:64, colormap('jet'), linspace(1, 64, length(unique(label))));

showme = 61;
figure
subplot(211);
prettyline(t, squeeze(rwins(showme, :, pairs(2,:))), label, colors);
hold on;
plot(t, mean(squeeze(rwins(showme, :, pairs(1,:))),2), 'k', 'linew', 2);
title(num2str(showme));

ylim([-100e-6 100e-6]);
xlim([0 0.04]);

subplot(212);
prettyline(t, squeeze(rwins(showme, :, pairs(2,:)))-squeeze(rwins(showme, :, pairs(1,:))), label, colors);
ylim([-100e-6 100e-6]);
xlim([0 0.04]);


return