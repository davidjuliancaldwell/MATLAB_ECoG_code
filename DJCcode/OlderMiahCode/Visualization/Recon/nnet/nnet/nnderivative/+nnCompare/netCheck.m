function problem = netCheck(net,hints,usesGradient,usesJacobian)

% Copyright 2012 The MathWorks, Inc.

for i=1:hints.numTools
  problem = hints.subcalcs{i}.netCheck(net,hints.subcalcs{i}.hints,usesGradient,usesJacobian);
  if ~isempty(problem), return; end
end
problem = '';
