function hints = dataHints(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

if (hints.isActiveWorker)
  hints.subhints = hints.subcalc.dataHints(net,data,hints.subhints);
end
