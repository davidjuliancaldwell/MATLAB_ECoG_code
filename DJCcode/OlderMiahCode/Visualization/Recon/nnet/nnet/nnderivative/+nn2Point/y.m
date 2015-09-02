function [Y,Af] = y(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

if nargout == 2
  [Y,Af] = hints.subcalc.y(net,data,hints.subhints);
else
  Y = hints.subcalc.y(net,data,hints.subhints);
end
