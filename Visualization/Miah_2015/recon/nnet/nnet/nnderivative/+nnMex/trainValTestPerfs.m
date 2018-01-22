function [trainPerf,valPerf,testPerf,trainN,valN,testN] = trainValTestPerfs(net,data,hints)

numMasks = 3;
[Perfs,PerfN] = nnMex.perfs ...
  (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,data.masks,data.Q,data.TS,numMasks,hints);

trainPerf = Perfs(1);
valPerf = Perfs(2);
testPerf = Perfs(3);

trainN = PerfN(1);
valN = PerfN(2);
testN = PerfN(3);
