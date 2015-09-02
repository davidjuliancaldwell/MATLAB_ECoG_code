function [Y,Af] = y(net,data,hints)
%NNCALC_COMPARE.Y

% Copyright 2012 The MathWorks, Inc.

if nargout == 2
  [Y,Af] = hints.subcalcs{1}.y(net.subnets{1},data.subdata{1},hints.subhints{1});
else
  Y = hints.subcalcs{1}.y(net.subnets{1},data.subdata{1},hints.subhints{1});
end

for i=2:hints.numTools
  if nargout == 2
    [Y2,Af2] = hints.subcalcs{i}.y(net.subnets{i},data.subdata{i},hints.subhints{i});
  else
    Y2 = hints.subcalcs{i}.y(net.subnets{i},data.subdata{i},hints.subhints{i});
  end
  
  if any(size(Y) ~= size(Y2))
    error('Calculations are inconsistent.');
  end
  a = cell2mat(Y);
  b = cell2mat(Y2);
  if any(size(a) ~= size(b))
    error('Calculations are inconsistent.');
  end
  if any(isnan(a) ~= isnan(b))
    error('Calculations are inconsistent.');
  end
  if max(abs(a(:)-b(:))) > hints.accuracy
    error('Calculations are inconsistent.');
  end
  
  if nargout >= 2
    if any(size(Af) ~= size(Af2))
      error('Calculations are inconsistent.');
    end
    a = cell2mat(Af);
    b = cell2mat(Af2);
    if any(size(a) ~= size(b))
      error('Calculations are inconsistent.');
    end
    if any(isnan(a) ~= isnan(b))
      error('Calculations are inconsistent.');
    end
    if max(abs(a(:)-b(:))) > hints.accuracy
      error('Calculations are inconsistent.');
    end
  end
  
end
