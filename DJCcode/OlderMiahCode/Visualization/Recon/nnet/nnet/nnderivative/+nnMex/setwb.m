function net = setwb(net,wb,hints)

for i=1:hints.numLayers
  if hints.learnWB.bInclude(i)
    net(hints.allWB.bInd{i}) = wb(hints.learnWB.bInd{i});
  end
  for j=1:hints.numInputs
    if hints.learnWB.iwInclude(i,j)
      net(hints.allWB.iwInd{i,j}) = wb(hints.learnWB.iwInd{i,j});
    end
  end
  for j=1:hints.numLayers
    if hints.learnWB.lwInclude(i,j)
      net(hints.allWB.lwInd{i,j}) = wb(hints.learnWB.lwInd{i,j});
    end
  end
end
