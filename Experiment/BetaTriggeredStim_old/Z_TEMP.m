%% Constants
Z_Constants;
addpath ./scripts;

%% parameters

% need to be fixed to be nonspecific to subject

% sid = SIDS{1};
% tp = 'd:\research\subjects\d5cd55\data\d8\d5cd55_BetaTriggeredStim';
% block = 'Block-49';
% chans = 1:64;
% stims = [62 54];
% bads = [];
% N = 1563;

% sid = SIDS{2};
% tp = 'd:\research\subjects\c91479\data\d7\c91479_BetaTriggeredStim';
% block = 'BetaPhase-14';
% stims = [55 56];
% chans = 1:64;
% bads = [1];
% N= 2823;

sid = SIDS{3};
tp = 'd:\research\subjects\7dbdec\data\d7\7dbdec_BetaTriggeredStim';
block = 'BetaPhase-17';
stims = [11 12];
chans = [1:64];
bads = [57 8];
N = 3246;

chans(ismember(chans, stims)) = [];

%% process each ecog channel individually
ax = [];

figure

awins = NaN*ones(64, 672, N);

for chan = chans
    if (~ismember(chan, bads))
        fprintf('.');
        load(fullfile(META_DIR, sid, num2str(chan)), 'wins', 'efs');
        awins(chan, :, :) = wins;
        
%         ax(end+1) = subplot(8,8,chan);
%         plot(mean(wins, 2), 'color', 'r', 'linew', 2);
%         ylim([-100e-6 100e-6]);
    end
end

save(fullfile(META_DIR, sid, 'all'), 'awins', 'efs', 'stims', 'bads');

return
% linkaxes(ax, 'xy');

%%
foo = squeeze(mean(awins, 3));
efoo = foo;
goods = ~any(isnan(foo),2);

[win, proj, varfrac] = mpca(zscore(foo(goods, :)'));
% win = mean(zscore(foo(1:16,:)')')';

for chan = chans
    if (~ismember(chan, bads))
        plot(foo(chan, :));
        hold all;
        efoo(chan, :) = scaledExtract(foo(chan, :)', win(:, 1));
        plot(efoo(chan, :));
        efoo(chan, :) = scaledExtract(efoo(chan, :)', win(:, 2));
        plot(efoo(chan, :));
        efoo(chan, :) = scaledExtract(efoo(chan, :)', win(:, 3));
        plot(efoo(chan, :));
        hold off;
    end
end

    
%%
ax = [];

for chan = chans
    if (~ismember(chan, bads))

        ax(end+1) = subplot(8,8,chan);
        plot(foo(chan, :), 'color', 'r', 'linew', 2);
        hold on;
        plot(efoo(chan, :), 'color', 'k', 'linew', 2);
        ylim([-100e-6 100e-6]);
    end
end

% linkaxes(ax, 'xy');
    