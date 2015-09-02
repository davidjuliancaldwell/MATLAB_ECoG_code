function dperf = forwardprop(dy,t,y,e,param)
%MSE.FORWARDPROP

% Copyright 2012 The MathWorks, Inc.

dperf = bsxfun(@times,dy,-sign(e));
