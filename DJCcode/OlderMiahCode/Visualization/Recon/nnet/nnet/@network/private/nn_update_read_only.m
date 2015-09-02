function net = update_read_only(net)

% Copyright 2010 The MathWorks, Inc.

net.numOutputs = sum(net.outputConnect);

numInputDelays = 0;
for i=1:net.numLayers
  for j=find(net.inputConnect(i,:))
    numInputDelays = max([numInputDelays net.inputWeights{i,j}.delays]);
  end
end
net.numInputDelays = numInputDelays;

numLayerDelays = 0;
for i=1:net.numLayers
  for j=find(net.layerConnect(i,:))
    numLayerDelays = max([numLayerDelays net.layerWeights{i,j}.delays]);
  end
end
net.numLayerDelays = numLayerDelays;

numFeedbackDelays = 0;
for i=find(net.outputConnect)
  numFeedbackDelays = max([numFeedbackDelays net.outputs{i}.feedbackDelay]);
end
net.numFeedbackDelays = numFeedbackDelays;

numWeights = 0;
for i=1:numel(net.IW)
  if net.inputConnect(i) && net.inputWeights{i}.learn
    numWeights = numWeights + numel(net.IW{i});
  end
end
for i=1:numel(net.LW)
  if net.layerConnect(i) && net.layerWeights{i}.learn
    numWeights = numWeights + numel(net.LW{i});
  end
end
for i=1:numel(net.b)
  if net.biasConnect(i) && net.biases{i}.learn
    numWeights = numWeights + numel(net.b{i});
  end
end
net.numWeightElements = numWeights;
