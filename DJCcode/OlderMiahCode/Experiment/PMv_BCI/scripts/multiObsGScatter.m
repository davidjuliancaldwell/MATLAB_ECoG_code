function handle = multiObsGScatter(x, y, l, func)
    handle = figure;
    
    % plot the individuals 
    gscatter(x, y, l, '.');
    
    uls = unique(l);
    
    for uli = 1:length(uls)
        idxs = find(l == uls(uli));
        xs(uli) = func(x(idxs));
        ys(uli) = func(y(idxs));
    end
    
    scatter(xs, ys, 'ok', 'markersize', 10);
end