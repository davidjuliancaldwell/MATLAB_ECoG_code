function dx = forwardpropReverse(dy,x,y,settings)
%MAPMINMAX.FORWARDPROP_REVERSE

% Copyright 2012 The MathWorks, Inc.

dx = bsxfun(@rdivide,dy,settings.gain);
