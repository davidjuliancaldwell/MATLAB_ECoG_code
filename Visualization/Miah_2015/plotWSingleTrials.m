function plotWSingleTrials(x, y, color)
    % right now has no error checking
    % assuming y to be a matrix where size(y,1) == length(x)
    % and we average across the second dimension of y
    
    washeld = ishold(gca);
    
    if (washeld == false)
        hold on;
    end
    
    plot(x, y, [color ':']);
    plot(x, squeeze(mean(y,2)), color, 'LineWidth', 2);
    
    if (washeld == false)
        hold off;
    end
    
    axis tight;
    
end