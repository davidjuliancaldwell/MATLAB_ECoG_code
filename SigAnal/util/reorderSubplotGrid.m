function order = reorderSubplotGrid(start, direction, gridSize)
% function reorderSubplotGrid(start, direction, gridSize)
% start is a string, some combination of R or L and T or B, determining
%   where electrode 1 is relative to the rest of the grid, for example,
%   'RT' would mean the first electrode is in the top right corner of the
%   grid as you look at it.
% direction is a string, and is either C or O, the direction that 
%   electrodes count from electrode 1, C being clockwise and O being
%   counterclockwise.
% grid size is a two element array giving the grid dimensions
% order is a vector with length equal to the number of electrodes specified
%   by gridSize, that gives the subplot indices necessary to plot a figure
%   with the subplots organized anatomically

    % error check arguments
    switch start
        case 'RB'
            rotCt = 2;
        case 'RT'
            rotCt = 3;
        case 'LB'
            rotCt = 1;
        case 'LT'
            rotCt = 0;
        otherwise
            fprintf('inapproriate entry for start\n');
            reorderSubplotGrid_usage;
            return;
    end
    
    switch direction
        case 'C'
            flip = false;
        case 'O'
            flip = true;
        otherwise
            fprintf('inappropriate entry for direction\n');
            reorderSubplotGrid_usage;
            return;
    end
    
    if (length(gridSize) ~= 2)
        fprintf('gridSize must be a two element vector\n');
        reorderSubplotGrid_usage;
    end
    
    % matlab numbers subplots 
    %  1   2
    %  3   4
    
    % so the matrix, order, will need to be rotated accordingly and then
    % flipped as necessary
    % order is now subplot oriented
    order = reshape(1:(gridSize(1)*gridSize(2)), gridSize)';

    if (flip)
        order = order';
    end
    
    order = rot90(order, rotCt);
    
end

function reorderSubplotGrid_usage
    fprintf('run the command `doc reorderSubplotGrid` for more instructions\n');
end