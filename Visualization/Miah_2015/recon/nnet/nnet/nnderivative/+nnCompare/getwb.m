function wb = getwb(net,hints)

% Copyright 2012 The MathWorks, Inc.

wb = hints.subcalcs{1}.getwb(net.subnets{1},hints.subhints{1});

for i=2:hints.numTools
  wb2 = hints.subcalcs{i}.getwb(net.subnets{i},hints.subhints{i});
  
  if any(size(wb) ~= size(wb2))
    error('Calculations are inconsistent.');
  end
  if any(isnan(wb) ~= isnan(wb2))
    error('Calculations are inconsistent.');
  end
  if max(abs(wb - wb2)) > hints.accuracy
    error('Calculations are inconsistent.');
  end
end
