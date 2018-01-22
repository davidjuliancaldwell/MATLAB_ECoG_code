function [trainPerf,trainN] = trainPerf(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

trainPerf = 0;
trainN = 0;
for i=1:hints.numSlices

  % Slice Data
  qq = hints.sliceIndices{i};
  dataSlice = nncalc.split_data(data,qq);
  dataSlice = hints.subcalc.formatData(dataSlice,hints.subhints);
  
  % Calculate Slice
  [trainPerfSlice,trainNSlice] = hints.subcalc.trainPerf(net,dataSlice,hints.subhints);

  % Accumulate Results
  trainPerf = trainPerf + trainPerfSlice;
  trainN = trainN + trainNSlice; 
end

if (nargout < 2) && hints.perfNorm
  trainPerf = trainPerf / trainN;
end
