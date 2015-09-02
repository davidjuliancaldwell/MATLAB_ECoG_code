function net = nn_configure_bias(net,i)

% Copyright 2010 The MathWorks, Inc.

% Configure Size
net.biases{i}.size = net.layers{i}.size;

% Initialize
if any(size(net.b{i}) ~= [net.layers{i}.size 1])
  net.b{i} = zeros(net.layers{i}.size,1);
end
if ~isempty(net.initFcn)
  net = feval(net.initFcn,'initialize',net,'b',i);
end
