function Pd = pd(net,Pc,Q,TS,hints)
%NNCALC_MATLAB.PD

% Copyright 2012 The MathWorks, Inc.

Pd = hints.subcalcs{1}.pd(net,X,Xi,Q,TS,hints.subhints{1});

for i=2:hints.numTools
  Pd2 = hints.subcalcs{i}.pd(net,X,Xi,Q,TS,hints.subhints{i});
  
  if any(size(Pd) ~= size(Pd2))
    error('Calculations are inconsistent.');
  end
  
  for j=1:numel(Pd)
    a = cell2mat(Pd{j});
    b = cell2mat(Pd2{j});
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

