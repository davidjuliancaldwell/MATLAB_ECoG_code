function MakeReconImages(subjid, hemi)
    figure;
    PlotCortex(subjid, hemi);
    PlotElectrodes(subjid);
    maximize;
    
    mpath = fullfile (getSubjDir(subjid), 'images');
    TouchDir(mpath);

    if (strcmp(hemi, 'l') || strcmp(hemi, 'r'))
        SaveFig(mpath, [subjid '-lat'], 'png', '-r300');
        
        if (strcmp(hemi, 'l'))
            view(90, 0);
            SaveFig(mpath, [subjid '-med'], 'png', '-r300');
        else
            view(270, 0);
            SaveFig(mpath, [subjid '-med'], 'png', '-r300');
        end
    elseif (strcmp(hemi, 'b'))
        view(90,0);
        SaveFig(mpath, [subjid '-right'], 'png', '-r300');
        view(270, 0);
        SaveFig(mpath, [subjid '-left'], 'png', '-r300');
    end
    
    view(180, -90);
    SaveFig(mpath, [subjid '-inf'], 'png', '-r300');    
    
    close;
    
    fprintf('recon images have been generated to %s.\n', mpath);    
end