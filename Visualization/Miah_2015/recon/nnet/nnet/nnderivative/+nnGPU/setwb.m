function net = setwb(net,wb,hints)

% Net is (hints.gpuAllWB x 1)
% WB is (hints.matlabLearnWB x 1)

% Start with all original WB (both learning and non-learning WB)
gpuWB = hints.startGPUWB;
if isempty(gpuWB)
  return
end

% Copy from matlabLearnWB to gpuAllWB
fromInd = hints.matlabLearnWB.bInd;
toInd = hints.gpuAllWB.bInd;
for i=1:numel(fromInd)
  ind = fromInd{i};
  if ~isempty(ind)
    gpuWB(toInd{i}) = wb(ind);
  end
end

fromInd = hints.matlabLearnWB.iwInd;
toInd = hints.gpuAllWB.iwInd;
for i=1:numel(fromInd)
  ind = fromInd{i};
  if ~isempty(ind)
    gpuWB(toInd{i}) = wb(ind);
  end
end

fromInd = hints.matlabLearnWB.lwInd;
toInd = hints.gpuAllWB.lwInd;
for i=1:numel(fromInd)
  ind = fromInd{i};
  if ~isempty(ind)
    gpuWB(toInd{i}) = wb(ind);
  end
end

% Copy all WB to GPU
net(:) = gpuWB;
