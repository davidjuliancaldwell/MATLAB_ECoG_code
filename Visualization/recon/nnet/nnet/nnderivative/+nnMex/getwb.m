function wb = getwb(net,hints)

wb = zeros(hints.learnWB.wbLen,1);

for i=1:hints.numLayers
  if hints.learnWB.bInclude(i)
    wb(hints.learnWB.bInd{i}) = net(hints.allWB.bInd{i});
  end
  for j=1:hints.numInputs
    if hints.learnWB.iwInclude(i,j)
      wb(hints.learnWB.iwInd{i,j}) = net(hints.allWB.iwInd{i,j});
    end
  end
  for j=1:hints.numLayers
    if hints.learnWB.lwInclude(i,j)
      wb(hints.learnWB.lwInd{i,j}) = net(hints.allWB.lwInd{i,j});
    end
  end
end
