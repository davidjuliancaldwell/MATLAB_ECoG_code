%% Constants
Z_Constants;
addpath ./scripts;

%% parameters

% % need to be fixed to be nonspecific to subject
% sid = SIDS{1};
% tp = 'd:\research\subjects\d5cd55\data\d8\d5cd55_BetaTriggeredStim';
% block = 'Block-49';
% stims = [54 62];
% chans = [53];
% % chans = 49:64;

sid = SIDS{2};
tp = 'd:\research\subjects\c91479\data\d7\c91479_BetaTriggeredStim';
block = 'BetaPhase-14';
stims = [55 56];
chans = [48 63 64];

% chans(ismember(chans, stims)) = [];

%% load in the trigger data
load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');

% drop any stims that happen in the first 500 milliseconds
stims(:,stims(2,:) < fs/2) = [];

% drop any probe stimuli without a corresponding pre-burst/post-burst
bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));
stims(:, bads) = [];
    
allwins = [];

%% process each ecog channel individually
for chan = chans
    
    %% load in ecog data for that channel
    fprintf('loeading in ecog data:\n');
    tic;    
    grp = floor((chan-1)/16);
    ev = sprintf('ECO%d', grp+1);
    achan = chan - grp*16;
    
    [eco, efs] = tdt_loadStream(tp, block, ev, achan);

    toc;

    %% process triggers
    presamps = round(0.010 * efs); % pre time in sec
    postsamps = round(0.033 * efs); % post time in sec

    fac = fs/efs;

    if (strcmp(sid, 'd5cd55'))
%         pts = stims(3,:)==0 & (stims(2,:) > 4.5e6);        
        pts = stims(3,:)==0 & (stims(2,:) > 4.5e6) & (stims(2, :) > 36536266);        
    end
    
    if (strcmp(sid, 'c91479'))
        pts = stims(3,:)==0;
    end
    
    ptis = round(stims(2,pts)/fac);

    t = (-presamps:postsamps)/efs;
    
    wins = squeeze(getEpochSignal(eco', ptis-presamps, ptis+postsamps+1));

    awins = wins - repmat(median(wins, 1), [length(t) 1]);
%     awins = detrend(wins);
    
    figure
    plot(1e3*t, 1e6*awins, 'color', [0.5 0.5 0.5]);
    hold on;
    plot(1e3*t, 1e6*mean(awins, 2), 'r', 'linew', 2);
    
    ylim([-130 50]);
    xlim(1e3*[min(t) max(t)]);
    vline(0, 'k:');
    
    xlabel('time (ms)');
    ylabel('ECoG (uV)');
    
    allwins = cat(3, allwins, wins);
end