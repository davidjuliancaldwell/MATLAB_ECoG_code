function net = setwb(net,wb,hints)

% Copyright 2012 The MathWorks, Inc.

for i=1:hints.numTools
  net.subnets{i} = hints.subcalcs{i}.setwb(net.subnets{i},wb,hints.subhints{i});
end

