function [trainPerf,valPerf,testPerf,JE,JJ,trainN,valN,testN] = perfsJEJJ(net,data,hints)

numMasks = 3;
switch hints.direction
  case {'default','forward'}
    [JE,JJ,Perfs,PerfN] = nnMex.fj ...
      (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,data.masks,...
      data.Q,data.TS,numMasks,hints);
  case 'backward'
    [JE,JJ,Perfs,PerfN] = nnMex.bj ...
      (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,data.masks,...
      data.Q,data.TS,numMasks,hints);
end

trainPerf = Perfs(1);
valPerf = Perfs(2);
testPerf = Perfs(3);
trainN = PerfN(1);
valN = PerfN(2);
testN = PerfN(3);

