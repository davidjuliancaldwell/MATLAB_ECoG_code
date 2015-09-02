function d = layer_delays(net)
%LAYER_DELAYS Number of delays associated with each neural network layer.
%
%  LD = LAYER_DELAYS(NET) returns the maximum layer weight delay
%  associated with the output of each layer of the network.

% Copyright 2010 The MathWorks, Inc.

d = zeros(net.numLayers,1);
for i = 1:net.numLayers
  for j=1:net.numLayers
    if net.layerConnect(j,i)
      d(i) = max(d(i),max(net.layerWeights{j,i}.delays));
    end
  end
end
