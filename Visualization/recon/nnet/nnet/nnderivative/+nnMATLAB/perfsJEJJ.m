function [trainPerf,valPerf,testPerf,JE,JJ,trainN,valN,testN] = perfsJEJJ(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

switch hints.direction
  case {'default','forward'}
    [JE,JJ,Perfs,PerfN] = nnMATLAB.fj ...
      (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,...
      {data.train.mask data.val.mask data.test.mask},data.Q,data.TS,hints);
  case 'backward'
    [JE,JJ,Perfs,PerfN] = nnMATLAB.bj ...
      (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,...
      {data.train.mask data.val.mask data.test.mask},data.Q,data.TS,hints);
end

trainPerf = Perfs(1);
valPerf = Perfs(2);
testPerf = Perfs(3);
trainN = PerfN(1);
valN = PerfN(2);
testN = PerfN(3);

