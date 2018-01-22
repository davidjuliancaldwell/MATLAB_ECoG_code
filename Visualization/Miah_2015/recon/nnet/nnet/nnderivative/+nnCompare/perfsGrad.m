function [trainPerf,valPerf,testPerf,gWB,trainN,valN,testN] = perfsGrad(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

[trainPerf,valPerf,testPerf,gWB,trainN,valN,testN] = ...
  hints.subcalcs{1}.perfsGrad(net.subnets{1},data.subdata{1},hints.subhints{1});

for i=2:hints.numTools
  [trainPerf2,valPerf2,testPerf2,gWB2,trainN2,valN2,testN2] = ...
    hints.subcalcs{i}.perfsGrad(net.subnets{i},data.subdata{i},hints.subhints{i});
  
  if isnan(trainPerf) ~= isnan(trainPerf2)
    error('Calculations are inconsistent.');
  end
  if abs(trainPerf-trainPerf2) > hints.accuracy
    error('Calculations are inconsistent.');
  end
  
  if isnan(valPerf) ~= isnan(valPerf2)
    error('Calculations are inconsistent.');
  end
  if abs(valPerf-valPerf2) > hints.accuracy
    error('Calculations are inconsistent.');
  end
  
  if isnan(testPerf) ~= isnan(testPerf2)
    error('Calculations are inconsistent.');
  end
  if abs(testPerf-testPerf2) > hints.accuracy
    error('Calculations are inconsistent.');
  end
  
  if any(size(gWB) ~= size(gWB2))
    error('Calculations are inconsistent.');
  end
  if isnan(isnan(gWB) ~= isnan(gWB2))
    error('Calculations are inconsistent.');
  end
  mag = sqrt(sumsqr(gWB));
  scale = mag + (mag==0);
  diff_abs = sqrt(sumsqr(gWB-gWB2));
  diff_rel = diff_abs/scale;
  if diff_rel > hints.relativeAccuracy
    error(['Relative inaccuracy: ' num2str(diff_rel) ' > ' num2str(hints.relativeAccuracy)]);
  end
  
  if any(size(trainN) ~= size(trainN2))
    error('Calculations are inconsistent.');
  end
  if any(isnan(trainN) ~= isnan(trainN2))
    error('Calculations are inconsistent.');
  end
  if trainN ~= trainN2
    error('Calculations are inconsistent.');
  end

  if any(size(valN) ~= size(valN2))
    error('Calculations are inconsistent.');
  end
  if any(isnan(valN) ~= isnan(valN2))
    error('Calculations are inconsistent.');
  end
  if valN ~= valN2
    error('Calculations are inconsistent.');
  end

  if any(size(testN) ~= size(testN2))
    error('Calculations are inconsistent.');
  end
  if any(isnan(testN) ~= isnan(testN2))
    error('Calculations are inconsistent.');
  end
  if testN ~= testN2
    error('Calculations are inconsistent.');
  end
end
