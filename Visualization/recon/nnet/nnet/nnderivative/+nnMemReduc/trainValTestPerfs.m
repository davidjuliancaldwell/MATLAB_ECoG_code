function [trainPerf,valPerf,testPerf,trainN,valN,testN] = trainValTestPerfs(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

trainPerf = 0;
trainN = 0;
valPerf = 0;
valN = 0;
testPerf = 0;
testN = 0;
for i=1:hints.numSlices

  % Slice Data
  qq = hints.sliceIndices{i};
  dataSlice = nncalc.split_data(data,qq);
  dataSlice = hints.subcalc.formatData(dataSlice,hints.subhints);
  
  % Calculate Slice
  [trainPerfSlice,valPerfSlice,testPerfSlice,trainNSlice,valNSlice,testNSlice] = ...
    hints.subcalc.trainValTestPerfs(net,dataSlice,hints.subhints);

  % Accumulate Results
  trainPerf = trainPerf + trainPerfSlice;
  trainN = trainN + trainNSlice;
  valPerf = valPerf + valPerfSlice;
  valN = valN + valNSlice;
  testPerf = testPerf + testPerfSlice;
  testN = testN + testNSlice; 
end

if (nargout < 4) && hints.perfNorm
  trainPerf = trainPerf / trainN;
  valPerf = valPerf / valN;
  testPerf = testPerf / testN;
end
