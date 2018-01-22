function [Perfs,PerfN] = perfs(net,data,hints)
%NNCALC_MEMREDUC.PERFS

% Copyright 2012 The MathWorks, Inc.

Perfs = zeros(1,3);
PerfN = zeros(1,3);

for s = 1:hints.numSlices
  
  % Split Data
  qq = hints.sliceIndices{s};
  splitData = nncalc.split_data(data,qq);
  
  % Calculate Split
  [Perfsmr,PerfNmr] = hints.subcalc.perfs(net,splitData,hints.subhints);
  
  % Accumulate Data
  Perfs = Perfs + Perfsmr;
  PerfN = PerfN + PerfNmr;
end
