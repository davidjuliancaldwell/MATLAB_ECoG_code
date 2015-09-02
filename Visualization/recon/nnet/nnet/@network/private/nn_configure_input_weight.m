function net = nn_configure_input_weight(net,i,j,x)

% Copyright 2010 The MathWorks, Inc.

% Input Data
numDelays = length(net.inputWeights{i,j}.delays);
if nargin < 4
  if ~isempty(net.inputs{j}.exampleInput)
    % NNET 6.0 Compatibility
    x = net.inputs{j}.exampleInput;
  else
    x = net.inputs{j}.processedRange;
  end
  x = repmat(x,numDelays,1);
end

% Configure Size
rows = net.layers{i}.size;
cols = net.inputs{j}.processedSize * numDelays;
newSize = feval(net.inputWeights{i,j}.weightFcn,...
  'size',rows,cols,net.inputWeights{i,j}.weightParam);
net.inputWeights{i,j}.size = newSize;
if any(size(net.IW{i,j}) ~= newSize)
  net.IW{i,j} = zeros(newSize);
end

% Configure Initialization
if ~isempty(net.initFcn)
  net.inputWeights{i,j}.initSettings = ...
    feval(net.initFcn,'configure',net,'IW',i,j,x);
else
  net.inputWeights{i,j}.initSettings = struct;
end
