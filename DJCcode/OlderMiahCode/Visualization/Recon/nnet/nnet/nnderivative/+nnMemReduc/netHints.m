function hints = netHints(net,hints)

% Copyright 2012 The MathWorks, Inc.

% Dimensions
hints.numInputs = net.numInputs;
hints.numLayers = net.numLayers;
hints.numOutputs = net.numOutputs;
hints.numInputDelays = net.numInputDelays;
hints.numLayerDelays = net.numLayerDelays;
hints.input_sizes = nn.input_sizes(net);
hints.output_sizes = nn.output_sizes(net);
hints.layer_sizes = nn.layer_sizes(net);
hints.numWeightElements = net.numWeightElements;

% Performance
if isempty(net.performFcn)
  hints.perfNorm = false;
else
  hints.perfNorm = feval([net.performFcn '.normalize']);
end

hints.subhints = hints.subcalc.netHints(net,hints.subcalc.hints);
