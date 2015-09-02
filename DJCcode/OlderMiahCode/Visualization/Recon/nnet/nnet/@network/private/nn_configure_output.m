function net = nn_configure_output(net,i,t,dimensions,layerFlag)

% Copyright 2010 The MathWorks, Inc.

if nargin < 5
  layerFlag = false;
end

% Input Data
if nargin < 3
  if ~isempty(net.outputs{i}.exampleOutput)
    % NNET 6.0 Compatibility
    t = net.outputs{i}.exampleOutput;
  else
    t = net.layers{i}.range;
  end
else
  if ~isempty(net.outputs{i}.exampleOutput)
    % NNET 6.0 Compatibility
    net.outputs{i}.exampleOutput = t;
  end
end

% Configure Size
newSize = size(t,1);
net.outputs{i}.size = newSize;
net.outputs{i}.range = minmax(t);

% Configure Processing
numProcess = length(net.outputs{i}.processFcns);
net.outputs{i}.processSettings = cell(1,numProcess);
for j=1:numProcess
  processFcns = net.outputs{i}.processFcns{j};
  processParams = net.outputs{i}.processParams{j};
  [t,config] = feval(processFcns,t,processParams);
  net.outputs{i}.processSettings{j} = config;
end

% Size
newProcessedSize = size(t,1);
net.outputs{i}.processedSize = newProcessedSize;
net.outputs{i}.processedRange = minmax(t);

% Dimensions
if nargin < 4, dimensions = newProcessedSize; end

% Dependent Layer
oldLayerSize = net.layers{i}.size;
oldLayerDim = net.layers{i}.dimensions;
if ~layerFlag && ((oldLayerSize ~= newProcessedSize) || ((nargin>3) && any(oldLayerDim ~= dimensions)))
  net = nn_configure_layer(net,i,dimensions,true);
end

% TODO - Check layer/output ranges

