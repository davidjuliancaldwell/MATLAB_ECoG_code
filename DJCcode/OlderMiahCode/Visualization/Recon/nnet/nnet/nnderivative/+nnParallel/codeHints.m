function hints = codeHints(hints)

% Copyright 2012 The MathWorks, Inc.

if (hints.isActiveWorker)
  hints.subhints = hints.subcalc.codeHints(hints.subhints);
end
