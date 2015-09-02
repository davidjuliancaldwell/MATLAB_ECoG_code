function [gWB,trainPerf,trainN] = grad(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

gWB = zeros(hints.numWeightElements,1);
trainPerf = 0;
trainN = 0;
for i=1:hints.numSlices

  % Slice Data
  qq = hints.sliceIndices{i};
  dataSlice = nncalc.split_data(data,qq);
  dataSlice = hints.subcalc.formatData(dataSlice,hints.subhints);
  
  % Calculate Slice
  [gWBSlice,trainPerfSlice,trainNSlice] = hints.subcalc.grad(net,dataSlice,hints.subhints);

  % Accumulate Results
  gWB = gWB + gWBSlice;
  trainPerf = trainPerf + trainPerfSlice;
  trainN = trainN + trainNSlice;
end

if (nargout < 3) && hints.perfNorm
  gWB = gWB / max(1,trainN);
  trainPerf = trainPerf / trainN;
end
