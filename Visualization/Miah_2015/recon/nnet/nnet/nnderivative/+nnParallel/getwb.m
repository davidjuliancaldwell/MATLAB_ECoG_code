function wb = getwb(net,hints)

% Copyright 2012 The MathWorks, Inc.

if hints.isActiveWorker
  wb = hints.subcalc.getwb(net,hints.subhints);
else
  wb = [];
end
