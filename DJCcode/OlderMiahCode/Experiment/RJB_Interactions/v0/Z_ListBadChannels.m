SIDS = {'30052b', 'fc9643'};

for zid = SIDS
    sid = zid{:};
    
    bads = [];    
    files = interactionDataFiles(sid);
    cchan = [];
    
    for file = files
        load(strrep(file{:}, '.dat', '_montage.mat'));        
        bads = union(Montage.BadChannels, bads);        
    end
    
    fprintf('%s\n  ', sid);
    fprintf('%d ', bads);
    fprintf('cchan: %d', cchan);
    fprintf('\n\n');
end