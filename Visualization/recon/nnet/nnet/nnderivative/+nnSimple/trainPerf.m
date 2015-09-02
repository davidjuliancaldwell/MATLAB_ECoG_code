function [trainPerf,trainN] = trainPerf(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

[trainPerf,trainN] = nnSimple.perfs(net,data,{data.train.mask},hints);
