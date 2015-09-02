function [trainPerf,trainN] = trainPerf(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

[trainPerf,trainN] = nn7.perfs(net,data,{data.train.mask},hints);

if (nargout < 2) && hints.perfNorm
  trainPerf = trainPerf / trainN;
end

