%%
Z_Constants;
addpath ./scripts;

%%

for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    fprintf('working on %s\n', sid);
    
    load(fullfile(META_DIR, sprintf('%s_extracted.mat', sid)), 'trs', 'chanType');    
    
%     limits = [];
    
%     for chanIdx = 2:length(trs)
%         load(fullfile(META_DIR, sid, [num2str(trs(chanIdx)) '_simulations.mat']));        
%         limits = cat(3, limits, max(maxes, abs(mins)));
%     end
%     
%     confs = prctile(limits, 95, 3);
    
    for chanIdx = 2:length(trs)
        load(fullfile(META_DIR, sid, [num2str(trs(chanIdx)) '_interactions.mat']));        
        load(fullfile(META_DIR, sid, [num2str(trs(chanIdx)) '_simulations.mat']));        
        
        limits = max(maxes, abs(mins));
        confs = prctile(limits, 95, 3);
        
        
        FREQ_NAMES = {'HG-HG', 'Alpha-HG', 'HG-Alpha', 'Beta-HG', 'HG-Beta'};
        TYPE_NAMES = {'all', 'up', 'down', 'allearly', 'upearly', 'downearly', 'alllate', 'uplate', 'downlate'};
        
        freqs = 1:5;
        figure;

        for freqi = 1:length(freqs)
            freq = freqs(freqi);
                        
            types = 2:3;
            clim = max(max(max(max(abs(interactions(freqs,types,:,tkeepi))))));
            
            for typei = 1:length(types)
                type = types(typei);
                mint = squeeze(interactions(freq, type, :, tkeepi));
                mint(isnan(mint)) = 0;
                
                mint(abs(mint) > confs(freq, type)) = NaN;
                                                
                subplot(length(types), length(freqs), (typei-1)*length(freqs) + freqi);
                imagesc(tkeep, lags*(tkeep(2)-tkeep(1)), mint);                
                vline(0);hline(0);
%                 colorbar;
                
                title(sprintf('%s ctl-%d (%d) %s %s', sid, trs(chanIdx), chanType(chanIdx), FREQ_NAMES{freq}, TYPE_NAMES{type}));
                set(gca, 'clim', [-clim clim]);
            end
        end
        
        maximize;
        TouchDir(fullfile(OUTPUT_DIR, sid));
        SaveFig(fullfile(OUTPUT_DIR, sid), sprintf('%d-interactions', trs(chanIdx)));
        savefig(gcf, fullfile(OUTPUT_DIR, sid, sprintf('%d-interactions', trs(chanIdx))));
        close;
    end
end