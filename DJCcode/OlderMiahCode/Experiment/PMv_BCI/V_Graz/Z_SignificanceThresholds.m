Z_Constants;

for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    
    load(fullfile(META_DIR, [sid '_simulations.mat']));
    
    threshold(sIdx) = extractThreshold(allMax(:,:,2));    
    earlyThreshold(sIdx) = extractThreshold(earlyMax(:,:,2));
    lateThreshold(sIdx)  = extractThreshold(lateMax(:,:,2));
end

% save(fullfile(META_DIR, 'thresholds.mat'), '*hreshold');