function [trainPerf,valPerf,testPerf,JE,JJ,trainN,valN,testN] = perfsJEJJ(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

trainPerf = 0;
valPerf = 0;
testPerf = 0;
JE = zeros(net.numWeightElements,1);
JJ = zeros(net.numWeightElements,net.numWeightElements);
trainN = 0;
valN = 0;
testN = 0;

for i=1:hints.numSlices

  % Slice Data
  qq = hints.sliceIndices{i};
  dataSlice = nncalc.split_data(data,qq);
  dataSlice = hints.subcalc.formatData(dataSlice,hints.subhints);
  
  % Calculate Slice
  [trainPerfS,valPerfS,testPerfS,JES,JJS,trainNS,valNS,testNS] = hints.subcalc.perfsJEJJ(net,dataSlice,hints.subhints);
  
  % Accumulate Results
  trainPerf = trainPerf + trainPerfS;
  valPerf = valPerf + valPerfS;
  testPerf = testPerf + testPerfS;
  JE = JE + JES;
  JJ = JJ + JJS;
  trainN = trainN + trainNS;
  valN = valN + valNS;
  testN = testN + testNS;
end
