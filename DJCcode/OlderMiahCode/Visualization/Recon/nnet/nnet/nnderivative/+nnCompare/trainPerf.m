function [trainPerf,trainN] = trainPerf(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

if nargout < 2
  [trainPerf] = hints.subcalcs{1}.trainPerf(net.subnets{1},data.subdata{1},hints.subhints{1});
else
  [trainPerf,trainN] = hints.subcalcs{1}.trainPerf(net.subnets{1},data.subdata{1},hints.subhints{1});
end

for i=2:hints.numTools

  if nargout < 2
    [trainPerf2] = hints.subcalcs{i}.trainPerf(net.subnets{i},data.subdata{i},hints.subhints{i});
  else
    [trainPerf2,trainN2] = hints.subcalcs{i}.trainPerf(net.subnets{i},data.subdata{i},hints.subhints{i});
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

  if nargout >= 2
    if any(size(trainN) ~= size(trainN2))
      error('Calculations are inconsistent.');
    end
    if any(isnan(trainN) ~= isnan(trainN2))
      error('Calculations are inconsistent.');
    end
    if trainN ~= trainN2
      error('Calculations are inconsistent.');
    end
  end
end
