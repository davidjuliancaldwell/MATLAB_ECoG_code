function doBrainPlotWithDots(subjid, ts, ps)
    [~, hemi, Montage] = goalDataFiles(subjid);
    
%     h = figure;
    allLocs = trodeLocsFromMontage(subjid, Montage, false);
    
    l1Locs = allLocs(ps < 0.001, :);
    l2Locs = allLocs(ps >= 0.001 & ps < 0.05, :);
    nsigLocs = allLocs(ps >= 0.05, :);
    
    PlotDotsDirect(subjid, l1Locs,  ts(ps <  0.001), hemi, [-3 3], 15, 'recon_colormap', [], false, false);
    PlotDotsDirect(subjid, l2Locs,  ts(ps >= 0.001 & ps <  0.05), hemi, [-3 3], 8, 'recon_colormap', [], false, true);
    PlotDotsDirect(subjid, nsigLocs, ts(ps >= 0.05), hemi, [-3 3],  4, 'recon_colormap', [], false, true);
end