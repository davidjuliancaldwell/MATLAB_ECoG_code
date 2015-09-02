function [gWB,trainPerf,trainN] = grad(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

if nargout < 3
  [gWB,trainPerf] = hints.subcalcs{1}.grad(net.subnets{1},data.subdata{1},hints.subhints{1});
else
  [gWB,trainPerf,trainN] = hints.subcalcs{1}.grad(net.subnets{1},data.subdata{1},hints.subhints{1});
end
  
for i=2:hints.numTools
  if nargout < 3
    [gWB2,trainPerf2] = hints.subcalcs{i}.grad(net.subnets{i},data.subdata{i},hints.subhints{i});
  else
    [gWB2,trainPerf2,trainN2] = hints.subcalcs{i}.grad(net.subnets{i},data.subdata{i},hints.subhints{i});
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

  if any(size(trainPerf) ~= size(trainPerf2))
    error('Calculations are inconsistent.');
  end
  if any(isnan(trainPerf) ~= isnan(trainPerf2))
    error('Calculations are inconsistent.');
  end
  if max(abs(trainPerf(:)-trainPerf2(:))) > hints.accuracy
    error('Calculations are inconsistent.');
  end

  if nargout >= 3
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
