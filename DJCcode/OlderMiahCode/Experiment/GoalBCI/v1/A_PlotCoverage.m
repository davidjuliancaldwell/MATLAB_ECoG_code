% setup the path
addpath ./functions

Constants;
%%

for c = 1:length(SIDS)
    sid = SIDS{c};
    scode = SUBCODES{c};
    
    [~, hemi, Montage, ctl] = goalDataFiles(sid);
    
    figure;    
    locs = trodeLocsFromMontage(sid, Montage, false);
    w = ones(size(locs, 1), 1);
    w(Montage.BadChannels) = NaN;
    PlotDotsDirect(sid, locs, w, hemi, [0 1], 15, 'recon_colormap', 1:length(w), true, false);
        
    plot3(Montage.MontageTrodes(ctl, 1), Montage.MontageTrodes(ctl, 2), Montage.MontageTrodes(ctl, 3), 'bo', 'markersize', 18, 'linewidth', 3);

    if (c == 1)
        view(270,0);
    end
    maximize;
    
    title(scode);
    SaveFig(OUTPUT_DIR, sprintf('coverage %s', scode), 'png', '-r300');
end