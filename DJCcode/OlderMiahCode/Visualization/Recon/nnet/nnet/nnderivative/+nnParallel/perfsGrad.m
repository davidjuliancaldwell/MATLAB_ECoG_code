function [trainPerf,valPerf,testPerf,gWB,trainN,valN,testN] = perfsGrad(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

% Parallel Calculation
if hints.isActiveWorker
  [trainPerf,valPerf,testPerf,gWB,trainN,valN,testN] = ...
    hints.subcalc.perfsGrad(net,data,hints.subhints);
  results = {gWB trainPerf valPerf testPerf trainN, valN, testN};  
else
  results = {0 0 0 0 0 0 0};
end

% Combine Results on Worker 1
results = gop(@nncalc.sumParallelResults,results,hints.mainWorkerInd);
  
% Output Arguments
if (labindex == hints.mainWorkerInd)
  [gWB,trainPerf,valPerf,testPerf,trainN,valN,testN] = deal(results{:});
else
  [gWB,trainPerf,valPerf,testPerf,trainN,valN,testN] = deal([]);
end
