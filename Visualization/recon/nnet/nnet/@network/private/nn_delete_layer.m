function net = nn_delete_layer(net,i)
%NN_DELETE_LAYER Delete layer from network.

% Copyright 2010 The MathWorks, Inc.

if i > net.numLayers
  error(message('nnet:NNData:LayerIndexOutOfRange'));
end

% Remove related output
if net.outputConnect(i)
  net = nn_delete_output(net,i);
end

% Delete layer i
n = [(1:(i-1)) ((i+1):net.numLayers)];
net.numLayers = net.numLayers - 1;
net.layers = net.layers(n);
net.biasConnect = net.biasConnect(n);
net.biases = net.biases(n);
net.b = net.b(n);
net.inputConnect = net.inputConnect(n,:);
net.inputWeights = net.inputWeights(n,:);
net.IW = net.IW(n,:);
net.layerConnect = net.layerConnect(n,n);
net.layerWeights = net.layerWeights(n,n);
net.LW = net.LW(n,n);
net.outputConnect = net.outputConnect(n);
net.outputs = net.outputs(n);
