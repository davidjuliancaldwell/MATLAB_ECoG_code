function plotWSE(x, y, shapeColor, alphaVal, lineColorSpec, lineWidth)
    % right now has no error checking
    % assuming y to be a matrix where size(y,1) == length(x)
    % and we average across the second dimension of y
    
    if (~exist('lineWidth', 'var'))
        lineWidth = 1;
    end
    
    washeld = ishold(gca);
    
    stdErr = nanstd(y,0,2) / sqrt(size(y,2));
    
    yshape = zeros(size(y,1),2);
    yshape(:,1) = nanmean(y,2) + stdErr;
    yshape(:,2) = nanmean(y,2) - stdErr - yshape(:,1);
    
%     h = area(x, yshape, min(min(yshape)));
    h = area(x, yshape);
    set(h(2), 'FaceColor', shapeColor);
    set(h(2), 'EdgeColor', 'none');
    set(h(1), 'FaceColor', 'none');
    set(h(1), 'EdgeColor', 'none');
    set(h, 'BaseValue', min(min(cumsum(min(yshape)))));
    
    legendOff(h);
    
    alpha(alphaVal);
    
    if (washeld == false)
        hold on;
    end
    
    plot(x, squeeze(nanmean(y,2)), lineColorSpec, 'LineWidth', lineWidth);
    
    if (washeld == false)
        hold off;
    end
    
    axis tight;
    
end