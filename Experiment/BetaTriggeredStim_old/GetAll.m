%% Constants
Z_Constants;
addpath ./scripts;

%%
sid = SIDS{1};
tp = 'd:\research\subjects\d5cd55\data\d8\d5cd55_BetaTriggeredStim';
block = 'Block-49';
stims = [54 62];
refs  = [];
chans = 1:64;

bads = union(stims, refs);
goods = true(64,1);
goods(bads) = false;

eco = [];


for chan = chans
    
    %% load in ecog data for that channel
    fprintf('loeading in ecog data %d:\n', chan);
    tic;    
    grp = floor((chan-1)/16);
    ev = sprintf('ECO%d', grp+1);
    achan = chan - grp*16;
    
    [eco(:,chan), efs] = tdt_loadStream(tp, block, ev, achan);
    
    if (size(eco, 2) == 1)
        temp = eco;
        eco = zeros(size(temp, 1), 64);
        eco(:, 1) = temp;
    end
    
    toc;
end

for c = 1:size(eco, 1)
    mu = mean(eco(c, goods),2);
    eco(c, :) = eco(c, :) - mu;
end

%%
TouchDir(fullfile(META_DIR, sid));

for c = 1:size(eco, 2)
    fprintf('saving %d of %d\n', c, size(eco, 2));
    data = eco(:,c);
    save(fullfile(META_DIR, sid, num2str(c)), 'data', 'efs');
end