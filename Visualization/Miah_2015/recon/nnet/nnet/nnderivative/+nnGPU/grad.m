function [gWB,trainPerf,trainN] = grad(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

% Special case: No Gradient
if isempty(hints.dWB)
  gWB = zeros(hints.matlabLearnWB.wbLen,1);
  [trainPerf,trainN] = nnGPU.trainPerf(net,data,hints);
  return
end

numMasks = 1;
[hints.Perfs_and_N,hints.dWB,hints.TEMP] = feval(hints.bgKernel,...
  hints.Perfs_and_N,... % Output
  hints.dWB, ... % Output
  hints.TEMP, ...
  net,...
  data.X, data.Xi, data.Pc, data.Pd, ...
  data.Ac, ... % Temporary Storage
  data.T, data.EW, data.masks, ...
  int64(data.Q),int64(data.QAligned),int64(data.TS),...
  hints.long,int64(hints.sizeL),hints.double,int64(hints.sizeD),...
  int64(numMasks));

Perfs_and_N = gather(hints.Perfs_and_N);
Perfs = Perfs_and_N(1,:);
PerfN = Perfs_and_N(4,:);
trainPerf = sum(Perfs,2); % Reduce in MATLAB
trainN = sum(PerfN,2); % Reduce in MATLAB

gWB = sum(hints.dWB,2); % Reduce on GPU
gWB1 = gather(gWB);

gWB = zeros(hints.matlabLearnWB.wbLen,1);
if isempty(gWB)
  return
end

toInd = hints.matlabLearnWB.bInd;
fromInd = hints.gpuLearnWB.bInd;
for i=1:numel(toInd)
  ind = toInd{i};
  if ~isempty(ind)
    gWB(ind) = gWB1(fromInd{i});
  end
end

toInd = hints.matlabLearnWB.iwInd;
fromInd = hints.gpuLearnWB.iwInd;
for i=1:numel(toInd)
  ind = toInd{i};
  if ~isempty(ind)
    gWB(ind) = gWB1(fromInd{i});
  end
end

toInd = hints.matlabLearnWB.lwInd;
fromInd = hints.gpuLearnWB.lwInd;
for i=1:numel(toInd)
  ind = toInd{i};
  if ~isempty(ind)
    gWB(ind) = gWB1(fromInd{i});
  end
end
