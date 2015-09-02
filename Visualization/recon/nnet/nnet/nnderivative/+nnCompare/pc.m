function Pc = pc(net,X,Xi,Q,TS,hints)
%NNCALC_MATLAB.PC

% Copyright 2012 The MathWorks, Inc.

Pc = hints.subcalcs{1}.pc(net,X,Xi,Q,TS,hints.subhints{1});

for i=2:hints.numTools
  Pc2 = hints.subcalcs{i}.pc(net,X,Xi,Q,TS,hints.subhints{i});
  a = cell2mat(Pc);
  b = cell2mat(Pc2);
  
  if any(size(Pc) ~= size(Pc2))
    error('Calculations are inconsistent.');
  end
  
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

