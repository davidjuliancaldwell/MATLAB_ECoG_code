function h = PlotStates(sta, par, normalizeAndOffset)

    if (~exist('normalizeAndOffset', 'var'))
        normalizeAndOffset = 1;
    end
    
    names = fields(sta);
    
    h = figure;
    colors = 'rgbcmky';
    colidx = 1;
    
    if (normalizeAndOffset) 
        currentOffset = 0;
    end
    
    for name = names'
        
        value = double(sta.(name{:}));
        
        if (~exist('t', 'var'))
            t = (0:(length(value)-1))/par.SamplingRate.NumericValue;
        end
    
        if (normalizeAndOffset)
            value = map(value, min(value), max(value), 0, 1);
            value = value + currentOffset;
            currentOffset = currentOffset + 1;
        end
        
        plot(t, value, 'Color', colors(mod(colidx, length(colors))+1), 'LineWidth', floor(colidx/ (length(colors)))+1);
        
        if (~ishold)
            hold on;
        end
%         colidx = mod(colidx, length(colors))+1
        colidx = colidx + 1;
            
    end
    
    legend(names);
end