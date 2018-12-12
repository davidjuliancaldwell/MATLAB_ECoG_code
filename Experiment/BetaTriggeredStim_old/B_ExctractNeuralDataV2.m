%% Constants
Z_Constants;
addpath ./scripts;

%% parameters

% need to be fixed to be nonspecific to subject

% sid = SIDS{1};
% tp = 'd:\research\subjects\d5cd55\data\d8\d5cd55_BetaTriggeredStim';
% block = 'Block-49';
% stims = [54 62];
% chans = [4];

sid = SIDS{2};
tp = 'd:\research\subjects\c91479\data\d7\c91479_BetaTriggeredStim';
block = 'BetaPhase-14';
stims = [55 56];
chans = 63:64;

% sid = SIDS{3};
% tp = 'd:\research\subjects\7dbdec\data\d7\7dbdec_BetaTriggeredStim';
% block = 'BetaPhase-17';
% stims = [11 12];
% chans = [1:64];

chans(ismember(chans, stims)) = [];

%% load in the trigger data
load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');

% drop any stims that happen in the first 500 milliseconds
stims(:,stims(2,:) < fs/2) = [];

% drop any probe stimuli without a corresponding pre-burst/post-burst
bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));
stims(:, bads) = [];
    
% now identify the stimuli that we care about
pres = diff([stims(5, :) > 1.9 * fs 1]) == -1;

pairs = [];
pairs(1,:) = find(pres);

for c = 1:size(pairs, 2)    
    temp = stims(5,:) < 0.01 * fs;
    temp(1:pairs(1,c)) = 0;
    pairs(2,c) = find(temp, 1, 'first');

    pairs(3,c) = stims(6, pairs(1,c));
end

fprintf('number of test stimulus pairs passing through: %d\n', size(pairs, 2));

return
% load(fullfile(META_DIR, sid, 'all'), '-append', 'pairs', awins', 'efs', 'stims', 'bads');

%% process each ecog channel individually
for chan = chans
    
    %% load in ecog data for that channel
    fprintf('loeading in ecog data:\n');
    tic;    
    grp = floor((chan-1)/16);
    ev = sprintf('ECO%d', grp+1);
    achan = chan - grp*16;
    
    % raw data version
    [eco, efs] = tdt_loadStream(tp, block, ev, achan);

%     % bipolar montage version
%     [eco, efs] = tdt_loadStream(tp, block, ev, achan);
%     eco2 = tdt_loadStream(tp, block, ev, 16);
%     eco = eco-eco2;
    
%     % common average re-ref version
%     load(fullfile(META_DIR, sid, num2str(chan)));
%     eco = data'; clear data;
    
    toc;

    %% process triggers
    presamps = round(0.010 * efs); % pre time in sec
    postsamps = round(0.045 * efs); % post time in sec

    fac = fs/efs;

    if (strcmp(sid, 'd5cd55'))
%         pts = stims(3,:)==0 & (stims(2,:) > 4.5e6);        
        pts = stims(3,:)==0 & (stims(2,:) > 4.5e6) & (stims(2, :) > 36536266);        
    elseif (strcmp(sid, 'c91479'))
        pts = stims(3,:)==0;
    elseif (strcmp(sid, '7dbdec'))
        pts = stims(3,:)==0;
    else
        error 'unknown sid'; 
    end
    
    
    ptis = round(stims(2,:)/fac);

    t = (-presamps:postsamps)/efs;
    
    wins = squeeze(getEpochSignal(eco', ptis-presamps, ptis+postsamps+1));
    awins = adjustStims(wins);

    delta = [];
    for c = 1:size(pairs, 2);
        delta(:, c) = awins(:, pairs(2,c)) - awins(:, pairs(1, c));
    end

    reallybad = find(max(abs(delta(200:end,:))) > .001);
    if (~isempty(reallybad))
        warning('%d reallybads\n', numel(reallybad));
        delta(:, reallybad) = [];
        pairs(:,reallybad) = [];
    end

    label = bursts(4, pairs(3,:));
    labelGroupStarts = 1:7;
    labelGroupEnds   = [labelGroupStarts(2:end) Inf];
    
    for gIdx = 1:length(labelGroupStarts)
        labeli = label >= labelGroupStarts(gIdx) & label < labelGroupEnds(gIdx);
        label(labeli) = gIdx;
    end

    colors = interp1(1:64, colormap('jet'), linspace(1, 64, length(unique(label))));
    figure;
    prettyline(1e3*t, 1e6*delta, label, colors);

    ylim([-100 100]);
    xlim(1e3*[0.004 .045]);
    
    xlabel('time (ms)');
    ylabel('\Delta_{EP} (uV)');
    title(sprintf('EP By N_{CT}: %s, %d', sid, chan))
    
    leg = {};
    for d = 1:length(labelGroupStarts)
        if d == length(labelGroupStarts)
            leg{end+1} = sprintf('%d<=CT', labelGroupStarts(d));
        else
            leg{end+1} = sprintf('%d<=CT<%d', labelGroupStarts(d), labelGroupEnds(d));
        end        
    end
    legend(leg)

%     figure
% 
%     [slab, labi] = sort(label);
%     imagesc(delta(:, labi));
%     vline(find(diff(slab)))
%     set(gca, 'clim', [-50e-6 50e-6])

    tkeep = t > 5e-3 & t < 15e-3;
    lows = min(delta(tkeep, :));

    figure
    ax = gscatter(jitter(label, .1), 1e6*lows, label, colors);
%     ylabel('min of \Delta_{EP}');
    hold on;
    plot([0 max(label)+1], polyval(polyfit(label, 1e6*lows, 1), [0 max(label)+1]), 'k:', 'linew', 2);
    [r, p] = corr(label', lows');
    title(sprintf('r=%f, p=%f', r, p));


end