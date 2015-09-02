function PlotTrajectory(X, col, newFig)
% function PlotTrajectory(X, col, newFig)
% X is Tx3xM, where
%   T is the number of samples
%   3 is the 3 dimensions
%   M is the number of observations

    if (~exist('newFig', 'var') || newFig == true)
        figure;
    end        

    if (~exist('col', 'var'))
        col = [1 0 0];
    end
    

    scol = 0.8*([1 1 1] - col) + col;
    
    cm = [linspace(scol(1), col(1), size(X,3))' linspace(scol(1), col(2), size(X,3))' linspace(scol(1), col(3), size(X,3))'];
      
    for m = 1:size(X,3)
        ax = plot3(X(:,1,m), X(:,2,m), X(:,3,m), 'color', cm(m, :));
        hold on;
        legendOff(ax);
    end
    
    temp = mean(X, 3);
    plot3(temp(:,1), temp(:,2), temp(:,3), 'linewidth', 3, 'color', col);        
    hold on;
    ax = plot3(temp(1,1), temp(1,2), temp(1,3), 'o', 'color', col);
    legendOff(ax);
    ax = plot3(temp(end,1), temp(end,2), temp(end,3), 's', 'color', col);
    legendOff(ax);        
end