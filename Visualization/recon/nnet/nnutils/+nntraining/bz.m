function bz = bz(net,Q,hints)
%CALCBZ Calculate batch of biases

% Copyright 2010-2012 The MathWorks, Inc.

bz = cell(net.numLayers,1);
ones1xQ = ones(1,Q);
for i = find(net.biasConnect)'
  bz{i} = net.b{i}(:,ones1xQ);
end
