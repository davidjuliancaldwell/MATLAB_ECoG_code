function wb = getwb(net,hints)

wb = zeros(hints.matlabLearnWB.wbLen,1);
if isempty(wb)
  return
end

net = gather(net);

toInd = hints.matlabLearnWB.bInd;
fromInd = hints.gpuAllWB.bInd;
for i=1:numel(toInd)
  ind = toInd{i};
  if ~isempty(ind)
    wb(ind) = net(fromInd{i});
  end
end

toInd = hints.matlabLearnWB.iwInd;
fromInd = hints.gpuAllWB.iwInd;
for i=1:numel(toInd)
  ind = toInd{i};
  if ~isempty(ind)
    wb(ind) = net(fromInd{i});
  end
end

toInd = hints.matlabLearnWB.lwInd;
fromInd = hints.gpuAllWB.lwInd;
for i=1:numel(toInd)
  ind = toInd{i};
  if ~isempty(ind)
    wb(ind) = net(fromInd{i});
  end
end
