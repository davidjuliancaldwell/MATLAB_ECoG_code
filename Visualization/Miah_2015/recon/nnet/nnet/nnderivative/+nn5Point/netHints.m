function hints = netHints(net,hints)

% Copyright 2012 The MathWorks, Inc.

hints.output_sizes = nn.output_sizes(net);

if isempty(net.performFcn)
  hints.perfNorm = false;
else
  hints.perfNorm = feval([net.performFcn '.normalize']);
end

hints.subhints = hints.subcalc.netHints(net,hints.subcalc.hints);

