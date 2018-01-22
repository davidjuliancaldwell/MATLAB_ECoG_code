function [trainPerf,trainN] = trainPerf(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

if (nargout > 1)
  [trainPerf,trainN] = hints.subcalc.trainPerf(net,data,hints.subhints);
else
  trainPerf = hints.subcalc.trainPerf(net,data,hints.subhints);
end
