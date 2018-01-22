function ax = prettybox(data, groups, groupColors, linewidth, doNotch)
    if (doNotch)
        notchStr = 'on';
    else
        notchStr = 'off'
    end
    
    ax = boxplot(data, groups, 'notch', notchStr, 'symbol', 'ro');
    
    for boxes = 1:size(ax, 2)
        boxColor = groupColors(boxes, :);
        
        set(ax(1:6, boxes), 'color', boxColor);
        set(ax(7, boxes), 'markeredgecolor', boxColor);
        set(ax(1:6, boxes), 'linewidth', linewidth);
        set(ax(7, boxes), 'linewidth', 3);
        
        % ax(1, N) upper quartile v line
        set(ax(1, boxes), 'linestyle', '-');
        
        % ax(2, N) lower quartile v line
        set(ax(2, boxes), 'linestyle', '-');
        
        % ax(3, N) upper quartile h line
        set(ax(3, boxes), 'linestyle', 'none');
        
        % ax(4, N) lower quartile h line
        set(ax(4, boxes), 'linestyle', 'none');
        
        % ax(5, N) box outline
        % ax(6, N) median line
        % ax(7, N) outlier markers
    end
end