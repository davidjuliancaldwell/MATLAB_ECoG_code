function PlotGaussDirect(subject, locs, weights, viewSide, clims, colormap)

    basedir = getSubjDir(subject);
    
    if (strcmp(viewSide, 'r') || strcmp(viewSide, 'right'))
        load([basedir 'surf' filesep sprintf('%s_cortex_rh_hires.mat', subject)]);
    elseif (strcmp(viewSide, 'l') || strcmp(viewSide, 'left'))
        load([basedir 'surf' filesep sprintf('%s_cortex_lh_hires.mat', subject)]);
    else
        load([basedir 'surf' filesep sprintf('%s_cortex_both_hires.mat', subject)]);            
    end
           
    ctmr_gauss_plot(cortex, locs, weights, viewSide, clims, false, colormap);
end