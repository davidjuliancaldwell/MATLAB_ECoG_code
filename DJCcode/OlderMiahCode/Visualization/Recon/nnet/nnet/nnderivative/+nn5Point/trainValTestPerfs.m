function [trainPerf,valPerf,testPerf,trainN,valN,testN] = trainValTestPerfs(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

if (nargout >= 4)
  [trainPerf,valPerf,testPerf,trainN,valN,testN] = hints.subcalc.trainValTestPerfs(net,data,hints.subhints);
else
  [trainPerf,valPerf,testPerf] = hints.subcalc.trainValTestPerfs(net,data,hints.subhints);
end
