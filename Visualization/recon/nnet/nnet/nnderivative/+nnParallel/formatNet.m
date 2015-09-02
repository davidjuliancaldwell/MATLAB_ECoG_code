function net = formatNet(net,hints)

% Copyright 2012 The MathWorks, Inc.

if (hints.isActiveWorker)
  net = hints.subcalc.formatNet(net,hints.subhints);
else
  net = [];
end
