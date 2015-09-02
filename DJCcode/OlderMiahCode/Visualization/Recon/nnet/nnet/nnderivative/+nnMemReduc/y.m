function [Y,Af] = y(net,data,hints)
%NNCALC_MEMREDUC.Y

% Copyright 2012 The MathWorks, Inc.

Q = data.Q;
TS = data.TS;

Y = cell(hints.numOutputs,TS);
for i=1:hints.numOutputs
  Y(i,:) = {zeros(hints.output_sizes(i),Q)};
end

if nargout >= 2
  Af = cell(hints.numLayers,hints.numLayerDelays);
  for i=1:hints.numLayers
    Af(i,:) = {zeros(hints.layer_sizes(i),Q)};
  end
end

for s = 1:hints.numSlices
  
  % Slice Data
  qq = hints.sliceIndices{s};
  dataSlice = nncalc.split_data(data,qq);
  dataSlice = hints.subcalc.formatData(dataSlice,hints.subhints);
  
  % Calculate Slice
  [Ymr,Afmr] = hints.subcalc.y(net,dataSlice,hints.subhints);
  
  % Accumulate Results
  for i=1:hints.numOutputs
    for ts = 1:TS
      Y{i,ts}(:,qq) = Ymr{i,ts};
    end
  end
  
  if nargout >= 2
    for i=1:hints.numLayers
      for ts = 1:net.numLayerDelays
        Af{i,ts}(:,qq) = Afmr{i,ts};
      end
    end
  end
end
