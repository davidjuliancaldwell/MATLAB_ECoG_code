function sizes = layer_sizes(net)
%LAYER_SIZES Layer sizes of a neural network

% Copyright 2010 The MathWorks, Inc.

sizes = zeros(net.numLayers,1);
for i=1:net.numLayers
  sizes(i) = net.layers{i}.size;
end
