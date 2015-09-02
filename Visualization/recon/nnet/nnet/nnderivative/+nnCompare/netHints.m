function hints = netHints(net,hints)

% Copyright 2012 The MathWorks, Inc.

hints.subhints = cell(1,hints.numTools);
for i=1:hints.numTools
  hints.subhints{i} = hints.subcalcs{i}.netHints(net,hints.subcalcs{i}.hints);
end

if isempty(net.performFcn) || ~isfield(net.performParam,'normalization')
  hints.perfNorm = false;
else
  hints.perfNorm = feval([net.performFcn '.normalize']);
end

