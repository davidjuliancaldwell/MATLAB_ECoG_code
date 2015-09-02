function data = formatData(data,hints)

% Copyright 2012 The MathWorks, Inc.

if (hints.isActiveWorker)
  data = hints.subcalc.formatData(data,hints.subhints);
else
  data = [];
end
