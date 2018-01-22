function dx = backprop(dy,x,y,settings)
%MAPMINMAX.BACKPROP

% Copyright 2012 The MathWorks, Inc.

dx = bsxfun(@times,dy,settings.gain);
