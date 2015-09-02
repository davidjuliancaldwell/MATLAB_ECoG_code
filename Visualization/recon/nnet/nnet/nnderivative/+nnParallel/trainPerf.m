function [trainPerf,trainN] = trainPerf(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

% Parallel Calculation
if hints.isActiveWorker
  [trainPerf,trainN] = hints.subcalc.trainPerf(net,data,hints.subhints);
  results = {trainPerf trainN};
else
  results = {0 0};
end

% Combine Results on Worker 1
results = gop(@nncalc.sumParallelResults,results,hints.mainWorkerInd);
  
% Output Arguments
if (labindex == hints.mainWorkerInd)
  [trainPerf,trainN] = deal(results{:});
  if (nargout < 2) && hints.perfNorm
    trainPerf = trainPerf / trainN;
  end
else
  [trainPerf,trainN] = deal([]);
end

