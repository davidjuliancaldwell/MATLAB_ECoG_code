function PlotDots(subject, electrodeSubset, weights, viewSide, clims, markerSize, colormap)

    basedir = getSubjDir(subject);
    load([basedir 'trodes.mat']);
    
    if (strcmp(electrodeSubset, 'all') == 1)    
        electrodeSubset = TrodeNames;
    end
        
    trodeLocations = [];
    trodeLabels = [];
    
    % TODO needs to be able to handle various montages, e.g. Grid(1:64) or
    % Grid(:) or Grid
    
    
    for electrodeElt = electrodeSubset
        temp = electrodeElt{:};
        
        [st, en] = regexp(temp, '\([0-9]*:[0-9]*\)');
        if (~isempty(st))
            temp = [temp(1:en-1) ', :' temp(en:end)];
        end
        
        if(strcmp('empty', temp(1:5)) == false)
            eval(sprintf('trodeLocations = [trodeLocations; %s];', temp));
            eval(sprintf('trodeLabels    = [trodeLabels 1:size(%s, 1)];', temp));
        else
            % remove weights for the "empty" channels
            eval(sprintf('lengthToRemove = length(%s);', temp((st+1):(en-1))));
            weights((length(trodeLocations)+1) : (length(trodeLocations)+lengthToRemove)) = [];
        end
    end
    
    PlotDotsDirect(subject, trodeLocations, weights, viewSide, clims, markerSize, colormap, trodeLabels);        
end