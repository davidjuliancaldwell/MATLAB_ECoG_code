function [trainPerf,valPerf,testPerf,JE,JJ,trainN,valN,testN] = perfsJEJJ(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

[trainPerf,valPerf,testPerf,JE,JJ,gradient,trainN,valN,testN] = ...
  hints.subcalcs{1}.perfsJEJJ(net.subnets{1},data.subdata{1},hints.subhints{1});

for i=2:hints.numTools
  [trainPerf2,valPerf2,testPerf2,JE2,JJ2,gradient2,trainN2,valN2,testN2] = ...
    hints.subcalcs{i}.perfsJEJJ(net.subnets{i},data.subdata{i},hints.subhints{i});
  
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
  
  if any(size(JE) ~= size(JE2))
    error('Calculations are inconsistent.');
  end
  if isnan(isnan(JE) ~= isnan(JE2))
    error('Calculations are inconsistent.');
  end
  mag = sqrt(sumsqr(JE));
  scale = mag + (mag==0);
  diff_abs = sqrt(sumsqr(JE-JE2));
  diff_rel = diff_abs/scale;
  if diff_rel > hints.relativeAccuracy
    error('Calculations are inconsistent.');
  end
  
  if any(size(JJ) ~= size(JJ2))
    error('Calculations are inconsistent.');
  end
  if isnan(isnan(JJ(:) ~= isnan(JJ2(:))))
    error('Calculations are inconsistent.');
  end
  mag = sqrt(sumsqr(JJ(:)));
  scale = mag + (mag==0);
  diff_abs = sqrt(sumsqr(JJ(:)-JJ2(:)));
  diff_rel = diff_abs/scale;
  if diff_rel > hints.relativeAccuracy
    error('Calculations are inconsistent.');
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
