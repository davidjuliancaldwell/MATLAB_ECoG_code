function dy = backprop(dx,x,y,settings)
%MAPMINMAX.BACKPROP

% Copyright 2012 The MathWorks, Inc.

dy = bsxfun(@rdivide,dx,settings.gain);
