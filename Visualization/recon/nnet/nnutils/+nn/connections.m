function hints = connections(net,hints)

% Copyright 2012 The MathWorks, Inc.

if nargin < 2, hints = struct; end

% CONNECTIONS
% inputConnectFrom{i}
% inputConnectTo{i}
% layerConnectFrom{i}
% layerConnectTo{i}
hints.inputConnectFrom = cell(net.numLayers,1);
for i=1:net.numLayers
  hints.inputConnectFrom{i} = find(net.inputConnect(i,:));
end
hints.inputConnectTo = cell(net.numInputs,1);
for i=1:net.numInputs
  hints.inputConnectTo{i} = find(net.inputConnect(:,i)');
end
hints.layerConnectFrom = cell(net.numLayers,1);
hints.layerConnectTo = cell(net.numLayers,1);
for i=1:net.numLayers
  hints.layerConnectFrom{i} = find(net.layerConnect(i,:));
  hints.layerConnectTo{i} = find(net.layerConnect(:,i)');
end
