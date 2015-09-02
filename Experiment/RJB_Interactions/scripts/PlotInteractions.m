function PlotInteractions (fromLocations, toLocations, isDirectional)
    % fromLocations is Nx3, locations of starting points
    % toLocations is Nx3, locations of eding points
    % isDirectional is Nx1, boolean of whether or not to draw an arrowhead

    WIDTH = 2;
    LENGTH = 15;
    
    washeld = ishold;
    hold on;
    
    for c = 1:size(fromLocations, 1)
        if (isDirectional(c))
            arrow(fromLocations(c, :), toLocations(c, :), 'Width', WIDTH, 'Length', LENGTH);
        else
            arrow(fromLocations(c, :), toLocations(c, :), 'Width', WIDTH, 'Length', 0);
        end
    end

    if (~washeld)
        hold off;
    end
end