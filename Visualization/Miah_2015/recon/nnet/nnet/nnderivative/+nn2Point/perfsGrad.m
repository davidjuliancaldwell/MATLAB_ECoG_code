function [trainPerf,valPerf,testPerf,gWB,trainN,valN,testN] = perfsGrad(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

[~,valPerf,testPerf,~,valN,testN] = hints.subcalc.trainValTestPerfs(net,data,hints.subhints);
[gWB,trainPerf,trainN] = nn2Point.grad(net,data,hints);
