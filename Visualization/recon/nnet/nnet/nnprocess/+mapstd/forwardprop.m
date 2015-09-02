function dy = forwardprop(dx,x,y,settings)
%MAPMINMAX.FORWARDPROP

% Copyright 2012 The MathWorks, Inc.

dy = bsxfun(@times,dx,settings.gain);
