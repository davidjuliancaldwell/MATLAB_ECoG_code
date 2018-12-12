%% Constants
Z_Constants;
addpath ./scripts;

%% parameters

% need to be fixed to be nonspecific to subject

% sid = SIDS{1};

% sid = SIDS{2};

sid = SIDS{3};

%% load data

load(fullfile(META_DIR, sid, 'all'), 'awins', 'efs', 'stims', 'bads');

presamps = round(0.010 * efs); % pre time in sec
postsamps = round(0.045 * efs); % post time in sec
t = (-presamps:postsamps)/efs;



%%
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
    