function [trainPerf,valPerf,testPerf,trainN,valN,testN] = trainValTestPerfs(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

% Parallel Calculation
if hints.isActiveWorker
  [trainPerf,valPerf,testPerf,trainN,valN,testN] = hints.subcalc.trainValTestPerfs(net,data,hints.subhints);
  results = {trainPerf valPerf testPerf trainN valN testN};
else
  results = {0 0 0 0 0 0};
end

% Combine Results on Worker 1
results = gop(@nncalc.sumParallelResults,results,hints.mainWorkerInd);
  
% Output Arguments
if (labindex == hints.mainWorkerInd)
  [trainPerf,valPerf,testPerf,trainN,valN,testN] = deal(results{:});
  if (nargout < 4) && hints.perfNorm
    trainPerf = trainPerf / trainN;
    valPerf = valPerf / valN;
    testPerf = testPerf / testN;
  end
else
  [trainPerf,valPerf,testPerf,trainN,valN,testN] = deal([]);
end
