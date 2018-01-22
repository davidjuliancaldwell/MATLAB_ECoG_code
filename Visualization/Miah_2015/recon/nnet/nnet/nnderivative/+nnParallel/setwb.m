function net = setwb(net,wb,hints)

% Copyright 2012 The MathWorks, Inc.

wb = labBroadcast(hints.mainWorkerInd,wb);
if hints.isActiveWorker
  net = hints.subcalc.setwb(net,wb,hints.subhints);
else
  net = [];
end
