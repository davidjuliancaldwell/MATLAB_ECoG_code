Constants;

for zid = SIDS
    sid = zid{:};
    
    bads = [];    
    files = goalDataFiles(sid);
    cchan = [];
    
    for file = files
        load(strrep(file{:}, '.dat', '_montage.mat'));        
        bads = union(Montage.BadChannels, bads);                        
    end
    
    fprintf('%s\n  ', sid);
    fprintf('%d ', bads);
end