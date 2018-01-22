function PlotDotsDirect(subject, trodeLocations, weights, viewSide, clims, markerSize, colormapName, trodeLabels, plotLabels, doAsOverlay)
    % handle default values, without subject, trodeLocations, or weights,
    % the function won't work
    
    % colormap must be a string, either a built in colormap, or a .mat file
    % on the path containing a cm variable
    
    if (~exist('viewSide', 'var'))
        viewSide = 'both';
    end

    if (~exist('clims','var'))
        clims = [min(weights) max(weights)];
    else
        weights(weights > clims(2)) = clims(2);
        weights(weights < clims(1)) = clims(1);
    end

    if (~exist('markerSize','var'))
        markerSize = 15;
    end

    if (~exist('colormapName','var') || isempty(colormapName))
        load('loc_colormap');
    elseif (ischar(colormapName))
        if (~isBuiltinColormap(colormapName))
            load(colormapName);
        else
            cm = colormap(colormapName);        
        end
    else
        cm = colormapName;
    end
    
%     colormap(cm);
    
    if(~exist('trodeLabels', 'var') && ~isempty(trodeLabels))
        trodeLabels = 1:length(weights);
    end
    
    if(~exist('plotLabels', 'var'))
        plotLabels = true;
    end

    % first plot the subject's cortex
    v = viewSide;

    if (~exist('doAsOverlay', 'var') || doAsOverlay == false)
        PlotCortex(subject, viewSide);
    end

    % set up the color gradient
    minWeight = clims(1);
    maxWeight = clims(2);

    minColor = cm(1,:);
    maxColor = cm(end,:);

    alphas = (weights - minWeight) / (maxWeight - minWeight);
    idxs = alphas*length(cm);
    idxs = max(round(idxs), 1);
    
    set(gca, 'CLim', clims);
               
    for chan=1:length(weights)
        
        if (isnan(weights(chan)))
            plot3(trodeLocations(chan,1), trodeLocations(chan,2), trodeLocations(chan,3),'.','Color',[0 0 0], 'MarkerSize', round(max(markerSize)/2));
        else
            idx = idxs(chan);

%             startColor = cm(max(floor(idx), 1), :);
%             endColor   = cm(ceil(idx),:);

%             off = idx-floor(idx);
%             trueColor = (1 - off) * startColor + off * endColor;
            trueColor = cm(idx, :);

        %     trueColor = (1 - alpha) * minColor + alpha * maxColor;
            if (numel(markerSize) ~= 1)
                plot3(trodeLocations(chan,1),trodeLocations(chan,2),trodeLocations(chan,3),'o','MarkerFaceColor',trueColor,'MarkerSize',markerSize(chan),'MarkerEdgeColor','k')%i like red (white would be [1 1 1], etc) dots better                
            else
                plot3(trodeLocations(chan,1),trodeLocations(chan,2),trodeLocations(chan,3),'o','MarkerFaceColor',trueColor,'MarkerSize',markerSize,'MarkerEdgeColor','k')%i like red (white would be [1 1 1], etc) dots better
            end
            hold on;
%             diff = counts - chan;
%             idx = find(diff < 0, 1, 'last');
%             txt = num2str(-diff(idx));
            if (plotLabels)
                
                if (iscell(trodeLabels(chan)))
                    txt = trodeLabels{chan};
                else
                    txt = num2str(trodeLabels(chan));
                end
                
                t = text(trodeLocations(chan,1),trodeLocations(chan,2),trodeLocations(chan,3),txt,'FontSize',10,'HorizontalAlignment','center','VerticalAlignment','middle');
                set(t,'clipping','on');
            end
        end
    end
end