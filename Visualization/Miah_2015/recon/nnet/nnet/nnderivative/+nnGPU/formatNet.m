function net = formatNet(net1,hints)

% Get matlabAllWB
matlabWB = getwb(net1,hints.matlabAllWB);

% Copy matlabAllWB to gpuAllWB
gpuWB = zeros(hints.gpuAllWB.wbLen,1,hints.precision);

fromInd = hints.matlabAllWB.bInd;
toInd = hints.gpuAllWB.bInd;
for i=1:numel(fromInd)
  ind = fromInd{i};
  if ~isempty(ind)
    gpuWB(toInd{i}) = matlabWB(ind);
  end
end

fromInd = hints.matlabAllWB.iwInd;
toInd = hints.gpuAllWB.iwInd;
for i=1:numel(fromInd)
  ind = fromInd{i};
  if ~isempty(ind)
    gpuWB(toInd{i}) = matlabWB(ind);
  end
end

fromInd = hints.matlabAllWB.lwInd;
toInd = hints.gpuAllWB.lwInd;
for i=1:numel(fromInd)
  ind = fromInd{i};
  if ~isempty(ind)
    gpuWB(toInd{i}) = matlabWB(ind);
  end
end

net = gpuArray(gpuWB);