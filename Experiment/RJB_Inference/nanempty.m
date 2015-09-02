%% 8-14-2014, function to convert structure with NaNs to empty arrays
% this is to allow for cortex plotting of the whole data structure without
% issues when there there are no significant or interesting eletrodes. 

function [x] = nanempty(x)

    x(isnan(x)) = [];

end

