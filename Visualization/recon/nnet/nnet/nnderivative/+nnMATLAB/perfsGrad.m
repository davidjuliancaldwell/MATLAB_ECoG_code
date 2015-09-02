function [trainPerf,valPerf,testPerf,gWB,trainN,valN,testN] = perfsGrad(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

switch hints.direction
  case {'default','backward'}
    [gWB,Perfs,PerfN] = nnMATLAB.bg...
      (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,...
      {data.train.mask data.val.mask data.test.mask},data.Q,data.TS,hints);
  case 'forward'
    [gWB,Perfs,PerfN] = nnMATLAB.fg...
      (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,...
      {data.train.mask data.val.mask data.test.mask},data.Q,data.TS,hints);
end

  
trainPerf = Perfs(1);
valPerf = Perfs(2);
testPerf = Perfs(3);
trainN = PerfN(1);
valN = PerfN(2);
testN = PerfN(3);
