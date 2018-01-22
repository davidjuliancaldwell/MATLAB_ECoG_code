function hints = dataHints(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

hints.subhints = hints.subcalc.dataHints(net,data,hints.subhints);
