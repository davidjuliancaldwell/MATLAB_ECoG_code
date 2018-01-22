function net = nn_configure_layer(net,i,dimensions,outputFlag)

% Copyright 2010-2011 The MathWorks, Inc.

% TODO - do not reconfigure output if layer size does not change
% TODO - do not reconfigure layer if output size does not change

if nargin < 4, outputFlag = false; end
newSize = prod(dimensions);
oldSize = net.layers{i}.size;
sizeChange = newSize ~= oldSize;
range = repmat(feval(net.layers{i}.transferFcn,'outputRange'),newSize,1);

net.layers{i}.size = newSize;
net.layers{i}.range = range;
net.layers{i}.dimensions = dimensions;

% Configure Output
if ~outputFlag && net.outputConnect(i) && sizeChange
  net = nn_configure_output(net,i,range,dimensions,false);
end

if isempty(net.layers{i}.topologyFcn)
  net.layers{i}.positions = [];
  net.layers{i}.distances = [];
else
  net.layers{i}.positions = feval(net.layers{i}.topologyFcn,...
    net.layers{i}.dimensions);
  if isempty(net.layers{i}.distanceFcn)
    net.layers{i}.distances = [];
  else
    net.layers{i}.distances = feval(net.layers{i}.distanceFcn,net.layers{i}.positions);
  end
end

% Configure following weights
for j=find(net.layerConnect(:,i))'
  net = nn_configure_layer_weight(net,j,i,range);
end

% Resize bias
if net.biasConnect(i)
  net.biases{i}.size = net.layers{i}.size;
  if size(net.b{i},1) ~= net.layers{i}.size
    net.b{i} = zeros(net.biases{i}.size,1);
  end
end

% Resize preceding input weights
for j = find(net.inputConnect(i,:))
  net = nn_configure_input_weight(net,i,j,range);
end

% Resize preceding layer weights
for j = find(net.layerConnect(i,:))
  net = nn_configure_layer_weight(net,i,j,range);
end

