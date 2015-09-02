function [Perfs,PerfN] = perfs(net,data,hints)
%NNCALC_MATLAB.PERFS

% Copyright 2012 The MathWorks, Inc.

[Perfs,PerfN] = hints.subcalcs{1}.perfs(net.subnets{1},data.subdata{1},hints.subhints{1});

for i=2:hints.numTools
  [Perfs2,PerfN2] = hints.subcalcs{i}.perfs(net.subnets{i},data.subdata{i},hints.subhints{i});
  
  if any(size(Perfs) ~= size(Perfs2))
    error('Calculations are inconsistent.');
  end
  if any(isnan(Perfs) ~= isnan(Perfs2))
    error('Calculations are inconsistent.');
  end
  if max(abs(Perfs-Perfs2)) > hints.accuracy
    error('Calculations are inconsistent.');
  end
  
  if any(size(PerfN) ~= size(PerfN2))
    error('Calculations are inconsistent.');
  end
  if any(isnan(PerfN) ~= isnan(PerfN2))
    error('Calculations are inconsistent.');
  end
  if any(PerfN ~= PerfN2)
    error('Calculations are inconsistent.');
  end
end
