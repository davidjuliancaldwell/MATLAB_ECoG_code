function net = formatNet(net,hints)

% Copyright 2012 The MathWorks, Inc.

net1 = net;

net = struct;
net.subnets = cell(1,hints.numTools);
for i=1:hints.numTools
  net.subnets{i} = hints.subcalcs{i}.formatNet(net1,hints.subhints{i});
end
