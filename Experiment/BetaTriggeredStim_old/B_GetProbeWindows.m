%% Constants
Z_Constants;
addpath ./scripts;

%% parameters

% need to be fixed to be nonspecific to subject

sid = SIDS{1};
tp = 'd:\research\subjects\d5cd55\data\d8\d5cd55_BetaTriggeredStim';
block = 'Block-49';
stim = [54 62];
src = 61;
chans = 1:64;
bads = [];

% sid = SIDS{2};
% tp = 'd:\research\subjects\c91479\data\d7\c91479_BetaTriggeredStim';
% block = 'BetaPhase-14';
% stim = [55 56];
% src = 63;
% chans = 1:64;
% bads = 1;

% sid = SIDS{3};
% tp = 'd:\research\subjects\7dbdec\data\d7\7dbdec_BetaTriggeredStim';
% block = 'BetaPhase-17';
% stim = [11 12];
% src = 4;
% chans = [1:64];
% bads = [8 57];

%% load in the trigger data
load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');

%% process triggers
% drop any stims that happen in the first 500 milliseconds
stims(:,stims(2,:) < fs/2) = [];

% drop any probe stimuli without a corresponding pre-burst/post-burst
badstim = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));
stims(:, badstim) = [];

% drop a specific subset of the stims for each subject

if (strcmp(sid, 'd5cd55'))
    stims(:, (stims(2,:) < 4.5e6) & (stims(2, :) < 36536266)) = [];        
elseif (strcmp(sid, 'c91479'))
    % do nothing, but verify!
elseif (strcmp(sid, '7dbdec'))
    % do nothing
else
    error 'unknown sid'; 
end

probes = stims(:, stims(3,:) == 0);

% now identify the stimuli that we care about
pres = diff([probes(5, :) > 1.4 * fs 1]) == -1;

pairs = [];
pairs(1,:) = find(pres);

for c = 1:size(pairs, 2)    
    temp = probes(5,:) < 0.01 * fs;
    temp(1:pairs(1,c)) = 0;
    pairs(2,c) = find(temp, 1, 'first');

    pairs(3,c) = probes(6, pairs(1,c));
end

posts = false(size(pres));
posts(pairs(2,:)) = true;

fprintf('number of test stimulus pairs passing through: %d\n', size(pairs, 2));

%% prepare to grab the data for all probe stimuli
awins = [];

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

    if (chan == chans(1))
        fac = fs/efs;
        ptis = round(probes(2,:)/fac);
        
        presamps = round(0.010 * efs); % pre time in sec
        postsamps = round(0.045 * efs); % post time in sec

        t = (-presamps:postsamps)/efs;
    end
    
    toc;
    
    wins = squeeze(getEpochSignal(eco', ptis-presamps, ptis+postsamps+1));
    awins(chan, :, :) = wins;    
    
    if (size(awins, 1)==1)
        temp = awins;
        awins = zeros(length(chans), size(awins, 2), size(awins, 3));
        awins(1, :, :) = temp;
    end
end

save(fullfile(META_DIR, sid, 'all'), 't', 'awins', 'efs', 'probes', 'pres', 'pairs', 'posts', 'chans', 'bads', 'stim', 'src');