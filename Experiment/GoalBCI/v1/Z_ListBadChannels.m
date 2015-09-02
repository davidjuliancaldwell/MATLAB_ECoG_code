SIDS = {'d6c834', '6cc87c', 'ada1ab', '6b68ef'};

for zid = SIDS
    sid = zid{:};
    
    bads = [];    
    files = goalDataFiles(sid);
    cchan = [];
    
    for file = files
        load(strrep(file{:}, '.dat', '_montage.mat'));        
        bads = union(Montage.BadChannels, bads);        
        
        return
    end
    
    fprintf('%s\n  ', sid);
    fprintf('%d ', bads);
    fprintf('cchan: %d', cchan);
    fprintf('\n\n');
end