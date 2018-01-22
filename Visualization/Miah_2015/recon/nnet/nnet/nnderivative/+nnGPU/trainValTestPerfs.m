function [trainPerf,valPerf,testPerf,trainN,valN,testN] = trainValTestPerfs(net,data,hints)

% CALL KERNAL
numMasks = 3;
hints.Perfs_and_N = feval(hints.perfsKernel,...
  hints.Perfs_and_N,... % Output
  net,...
  data.X, data.Xi, data.Pc, data.Pd, ...
  data.Ac, ... % Temporary Storage
  data.T, data.EW, data.masks, ...
  int64(data.Q),int64(data.QAligned),int64(data.TS),...
  hints.long,int64(hints.sizeL),hints.double,int64(hints.sizeD),...
  int64(numMasks));

Perfs_and_N = gather(hints.Perfs_and_N);
Perfs = Perfs_and_N(1:numMasks,:);
PerfN = Perfs_and_N((numMasks+1):end,:);
Perfs = sum(Perfs,2)';
PerfN = sum(PerfN,2)';

trainPerf = Perfs(1);
valPerf = Perfs(2);
testPerf = Perfs(3);

trainN = PerfN(1);
valN = PerfN(2);
testN = PerfN(3);

