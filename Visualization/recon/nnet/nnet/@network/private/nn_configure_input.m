function net = nn_configure_input(net,i,x)

% Copyright 2010 The MathWorks, Inc.

% Input Data
if nargin < 3
  if ~isempty(net.inputs{i}.exampleInput)
    % NNET 6.0 Compatibility
    x = net.inputs{i}.exampleInput;
  else
    x = net.inputs{i}.range;
  end
else
  if ~isempty(net.inputs{i}.exampleInput)
    % NNET 6.0 Compatibility
    net.inputs{i}.exampleInput = x;
  end
end

% Configure Size
net.inputs{i}.size = size(x,1);
net.inputs{i}.range = minmax(x);

% Configure Processing
numProcess = length(net.inputs{i}.processFcns);
processFcns = net.inputs{i}.processFcns;
processParams = net.inputs{i}.processParams;
net.inputs{i}.processSettings = cell(1,numProcess);
for j=1:numProcess
  [x,config] = feval(processFcns{j},x,processParams{j});
  net.inputs{i}.processSettings{j} = config;
end

% Configure Size
net.inputs{i}.processedSize = size(x,1);
net.inputs{i}.processedRange = minmax(x);

% Configure Dependent Weights
layerToInd = find(net.inputConnect(:,i))';
for j = layerToInd
  net = nn_configure_input_weight(net,j,i,x);
end
