function [trainPerf,valPerf,testPerf,trainN,valN,testN] = trainValTestPerfs(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

masks = {data.train.mask data.val.mask data.test.mask};

[perfs,perfN] = nnSimple.perfs(net,data,masks,hints);

if (nargout < 4) && hints.perfNorm
  perfs = perfs ./ perfN;
else
  trainN = perfN(1);
  valN = perfN(2);
  testN = perfN(3);
end
trainPerf = perfs(1);
valPerf = perfs(2);
testPerf = perfs(3);
