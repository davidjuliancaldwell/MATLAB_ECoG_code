function y = repairSTWCPlot(x)
    % plot is lags x time
    % assume lags is odd
    
    mid = ceil(size(x, 1)/2);
    
    shifts = (1:size(x,1)) - mid;
    
    y = zeros(size(x));
    
    for c = 1:length(shifts)
        y(c, :) = circshift(x(c, :), [0 shifts(c)]);        
    end
%     y = circshift(x, shifts);
end