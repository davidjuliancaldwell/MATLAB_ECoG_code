function tickCchan(handle, cchan, axis)
    if (strcmpi(axis, 'x'))
        axtick = 'xtick';
        axticklabel = 'xticklabel';
    elseif (strcmpi(axis, 'y'))
        axtick = 'ytick';
        axticklabel = 'yticklabel';
    else
        error('unknown axis type, must be x or y');
    end
    
    % all this just to add a star for the cchan
    ticks = get(handle, axtick);
    ticks = sort(union(ticks, cchan));
    labs = {};
    labs(ticks~=cchan) = arrayfun(@(x) num2str(x), ticks(ticks~=cchan),'UniformOutput', false);
    labs{ticks==cchan} = '*';
    set(handle, axtick, ticks);                       
    set(handle, axticklabel, labs)            
end