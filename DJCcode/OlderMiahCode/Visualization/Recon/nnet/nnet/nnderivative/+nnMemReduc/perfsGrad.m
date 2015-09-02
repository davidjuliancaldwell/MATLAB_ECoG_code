function [trainPerf,valPerf,testPerf,gWB,trainN,valN,testN] = perfsGrad(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

trainPerf = 0;
valPerf = 0;
testPerf = 0;
gWB = zeros(net.numWeightElements,1);
trainN = 0;
valN = 0;
testN = 0;

for i=1:hints.numSlices

  % Slice Data
  qq = hints.sliceIndices{i};
  dataSlice = nncalc.split_data(data,qq);
  dataSlice = hints.subcalc.formatData(dataSlice,hints.subhints);
  
  % Calculate Slice
  [trainPerfS,valPerfS,testPerfS,gWBS,trainNS,valNS,testNS] = hints.subcalc.perfsGrad(net,dataSlice,hints.subhints);
  
  % Accumulate Results
  trainPerf = trainPerf + trainPerfS;
  valPerf = valPerf + valPerfS;
  testPerf = testPerf + testPerfS;
  gWB = gWB + gWBS;
  trainN = trainN + trainNS;
  valN = valN + valNS;
  testN = testN + testNS;
end
