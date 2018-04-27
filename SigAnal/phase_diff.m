function [delT] = phase_diff(diffs,f)
% takes in a difference in phase (radians), converts to time

delT = (1/f)*diffs*(1/(2*pi));

end

