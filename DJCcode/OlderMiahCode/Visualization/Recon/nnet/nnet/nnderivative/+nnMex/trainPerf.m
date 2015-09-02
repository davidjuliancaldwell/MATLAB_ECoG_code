function [trainPerf,trainN] = trainPerf(net,data,hints)

numMasks = 1;
[trainPerf,trainN] = nnMex.perfs ...
  (net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,data.trainMask,data.Q,data.TS,numMasks,hints);
