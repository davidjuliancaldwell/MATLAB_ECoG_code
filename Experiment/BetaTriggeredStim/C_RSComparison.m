%% Constants
Z_Constants;
addpath ./scripts;

%%
% sid = SIDS{1};
% tp = 'd:\research\subjects\d5cd55\data\d8\d5cd55_Baseline';
% block = 'Block-47';
% trig = [61];
% bads = [];

% sid = SIDS{2};
% tp = 'd:\research\subjects\c91479\data\d7\c91479_BetaTriggeredStim';
% block = 'BetaPhase-14';
% stims = [55 56];
% chans = [64 63 48];

sid = SIDS{3};
tp = strcat(SUB_DIR,'\7dbdec\data\d7\7dbdec_BetaTriggeredStim');
block = 'BetaPhase-16';
trig = [4];
bads = 57;

%%
chans = 1:64;
eco = [];

for chan = chans
    
    %% load in ecog data for that channel
    fprintf('loading in ecog data %d of %d:\n', chan, length(chans));
    tic;    
    grp = floor((chan-1)/16);
    ev = sprintf('ECO%d', grp+1);
    achan = chan - grp*16;
    
    % raw data version
    [eco(:,chan), efs] = tdt_loadStream(tp, block, ev, achan);
    
end

%% eliminate those strange spikes
for chan = chans
    locs = find(abs(zscore(eco(:, chan))) > 25);
    
    for loc = locs
        eco(loc,chan) = (eco(loc-1,chan)+eco(loc+1,chan))/2;
    end
end

%% common average re-reference and extract phase
goods = true(64, 1);
goods(bads) = false;

mu = mean(eco(:, goods), 2);
rawbeta = hilbert(bandpass(eco(:, trig), 12, 24, round(efs), 4));
refbeta = hilbert(bandpass(eco(:, trig)-mu, 12, 24, round(efs), 4));

rawphasor = rawbeta ./ abs(rawbeta);
refphasor = refbeta ./ abs(refbeta);

%%

difference = (rawphasor-refphasor);

binstarts = -pi:pi/100:(pi-pi/100);
binends   = (-pi+pi/100):pi/100:pi;

