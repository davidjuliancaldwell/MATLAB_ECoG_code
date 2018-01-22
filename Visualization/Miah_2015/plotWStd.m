function plotWStd(x, y, shapeColor, alphaVal, lineColorSpec)
    % right now has no error checking
    % assuming y to be a matrix where size(y,1) == length(x)
    % and we average across the second dimension of y
    
    washeld = ishold(gca);
    
    sigma = std(y,0,2);
    
    yshape = zeros(size(y,1),2);
    yshape(:,1) = mean(y,2) + sigma;
    yshape(:,2) = mean(y,2) - sigma - yshape(:,1);
    
%     h = area(x, yshape, min(min(yshape)));
    h = area(x, yshape);
    set(h(2), 'FaceColor', shapeColor);
    set(h(2), 'EdgeColor', 'none');
    set(h(1), 'FaceColor', 'none');
    set(h(1), 'EdgeColor', 'none');    
    alpha(alphaVal);
    
    if (washeld == false)
        hold on;
    end
    
    plot(x, squeeze(mean(y,2)), lineColorSpec);
    
    if (washeld == false)
        hold off;
    end
    
    axis tight;
    
end