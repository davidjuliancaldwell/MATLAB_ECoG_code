function [gWB,trainPerf,trainN] = grad(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

% Parallel Calculation
if hints.isActiveWorker
  [gWB,trainPerf,trainN] = hints.subcalc.grad(net,data,hints.subhints);
  results = {gWB trainPerf trainN};
else
  results = {0 0 0};
end

% Combine Results on Worker 1
results = gop(@nncalc.sumParallelResults,results,hints.mainWorkerInd);

% Output Arguments
if (labindex == hints.mainWorkerInd)
  [gWB,trainPerf,trainN] = deal(results{:});

  if (nargout < 3) && hints.perfNorm
    gWB = gWB / trainN;
    trainPerf = trainPerf / trainN;
  end
else
  [gWB,trainPerf,trainN] = deal([]);
end
