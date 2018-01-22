function PlotGauss(subject, electrodeSubset, weights, viewSide, clims, colormap)

    basedir = getSubjDir(subject);
    load([basedir 'trodes.mat']);
    
    if (strcmp(viewSide, 'r') || strcmp(viewSide, 'right'))
        load([basedir 'surf' filesep sprintf('%s_cortex_rh_hires.mat', subject)]);
    elseif (strcmp(viewSide, 'l') || strcmp(viewSide, 'left'))
        load([basedir 'surf' filesep sprintf('%s_cortex_lh_hires.mat', subject)]);
    else
        load([basedir 'surf' filesep sprintf('%s_cortex_both_hires.mat', subject)]);            
    end
        
            
    if (strcmp(electrodeSubset, 'all') == 1)    
        electrodeSubset = TrodeNames;
    end
        
    trodeLocations = [];
        
    for electrodeElt = electrodeSubset
        temp = electrodeElt{:};
        
        [st, en] = regexp(temp, '\([0-9]*:[0-9]*\)');
        if (~isempty(st))
            temp = [temp(1:en-1) ', :' temp(en:end)];
        end
        
        if(strcmp('empty', temp(1:5)) == false)
            eval(sprintf('trodeLocations = [trodeLocations; %s];', temp));
        else
            % remove weights for the "empty" channels
            eval(sprintf('lengthToRemove = length(%s);', temp((st+1):(en-1))));
            weights((length(trodeLocations)+1) : (length(trodeLocations)+lengthToRemove)) = [];
        end
    end
   
    ctmr_gauss_plot(cortex, trodeLocations, weights, viewSide, clims, false, colormap);
end