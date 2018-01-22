function [trainPerf,valPerf,testPerf,JE,JJ,trainN,valN,testN] = perfsJEJJ(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

% Parallel Calculation
if hints.isActiveWorker
  [trainPerf,valPerf,testPerf,JE,JJ,trainN,valN,testN] = ...
    hints.subcalc.perfsJEJJ(net,data,hints.subhints);
  results = {JE JJ trainPerf valPerf testPerf trainN valN testN};
else
  results = {0 0 0 0 0 0 0 0};
end

% Combine Results on Worker 1
results = gop(@nncalc.sumParallelResults,results,hints.mainWorkerInd);

% Output Arguments
if (labindex == hints.mainWorkerInd)
  [JE,JJ,trainPerf,valPerf,testPerf,trainN,valN,testN] = deal(results{:});
else
  [JE,JJ,trainPerf,valPerf,testPerf,trainN,valN,testN] = deal([]);
end
