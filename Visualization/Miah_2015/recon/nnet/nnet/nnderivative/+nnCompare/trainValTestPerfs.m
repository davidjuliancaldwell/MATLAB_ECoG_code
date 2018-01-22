function [trainPerf,valPerf,testPerf,trainN,valN,testN] = trainValTestPerfs(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

if nargout < 4
  [trainPerf,valPerf,testPerf] = ...
    hints.subcalcs{1}.trainValTestPerfs(net.subnets{1},data.subdata{1},hints.subhints{1});
else
  [trainPerf,valPerf,testPerf,trainN,valN,testN] = ...
    hints.subcalcs{1}.trainValTestPerfs(net.subnets{1},data.subdata{1},hints.subhints{1});
end

for i=2:hints.numTools

  if nargout < 4
    [trainPerf2,valPerf2,testPerf2] = ...
      hints.subcalcs{i}.trainValTestPerfs(net.subnets{i},data.subdata{i},hints.subhints{i});
  else
    [trainPerf2,valPerf2,testPerf2,trainN2,valN2,testN2] = ...
      hints.subcalcs{i}.trainValTestPerfs(net.subnets{i},data.subdata{i},hints.subhints{i});
  end

  if any(size(trainPerf) ~= size(trainPerf2))
    error('Calculations are inconsistent.');
  end
  if any(isnan(trainPerf) ~= isnan(trainPerf2))
    error('Calculations are inconsistent.');
  end
  if max(abs(trainPerf - trainPerf2)) > hints.accuracy
    error('Calculations are inconsistent.');
  end

  if any(size(valPerf) ~= size(valPerf2))
    error('Calculations are inconsistent.');
  end
  if any(isnan(valPerf) ~= isnan(valPerf2))
    error('Calculations are inconsistent.');
  end
  if max(abs(valPerf - valPerf2)) > hints.accuracy
    error('Calculations are inconsistent.');
  end

  if any(size(testPerf) ~= size(testPerf2))
    error('Calculations are inconsistent.');
  end
  if any(isnan(testPerf) ~= isnan(testPerf2))
    error('Calculations are inconsistent.');
  end
  if max(abs(testPerf - testPerf2)) > hints.accuracy
    error('Calculations are inconsistent.');
  end

  if nargout >= 4
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
end
