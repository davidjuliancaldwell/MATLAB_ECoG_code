function [trainPerf,valPerf,testPerf,gWB,trainN,valN,testN] = perfsGrad(net,data,hints)

numMasks = 3;
switch hints.direction
  case {'default','backward'}
    [gWB,Perfs,PerfN] = nnMex.bg ...
      (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,data.masks,...
      data.Q,data.TS,numMasks,hints);
  case 'forward'
    [gWB,Perfs,PerfN] = nnMex.fg ...
      (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,data.masks,...
      data.Q,data.TS,numMasks,hints);
end

trainPerf = Perfs(1);
valPerf = Perfs(2);
testPerf = Perfs(3);

trainN = PerfN(1);
valN = PerfN(2);
testN = PerfN(3);
