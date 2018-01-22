function dperf = forwardprop(dy,t,y,e,param)
%MSE.FORWARDPROP

% Copyright 2012 The MathWorks, Inc.

dperf = bsxfun(@times,dy,-2*e);
