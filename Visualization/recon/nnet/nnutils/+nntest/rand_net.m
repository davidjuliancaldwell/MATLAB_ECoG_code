function [net,seed] = rand_net(seed,enableDynamic)
%RAND_NET Random neural network.

% Copyright 2010-2012 The MathWorks, Inc.

% Enable Dynamic
if nargin < 2, enableDynamic = true; end

% Seed
if (nargin < 1) || isempty(seed)
  seed = 100*sum(clock);
  setdemorandstream(seed);
else
  setdemorandstream(seed);
end

% Function Choices
fcns = nntest.fcn_choices;

% Simulation Functions
netKind = floor(rand*4)+1;
switch netKind
  case 1, simFcns = nnMATLAB.netFcns;
  case 2, simFcns = nnMex.netFcns;
  case 3, simFcns = nnDependency.simulinkFcns;
  case 4, simFcns = nnGPU.netFcns;
end

% Number of Inputs
numInputs = floor(rand*3)+1;

% Number of Layers
numLayers = floor(rand*4)+1;

% Input Connect
inputMode = floor(4*rand)+1;
switch inputMode
  case 1, % First layer gets all inputs
    inputConnect = false(numLayers,numInputs);
    inputConnect(1,:) = true;
  case 2, % Each input goes to one random layer
    inputConnect = false(numLayers,numInputs);
    for i=1:numInputs
      inputConnect(floor(rand*numLayers)+1,i) = true;
    end
  case 3, % Each input goes to at least one random layer
    inputConnect = false(numLayers,numInputs);
    for i=1:numInputs
      inputConnect(:,i) = rand(numLayers,1) > 0.5;
      inputConnect(floor(rand*numLayers)+1,i) = true;
    end
  case 4, % All inputs to all layers
    inputConnect = true(numLayers,numInputs);
end

% Bias Connect
biasMode = floor(3*rand)+1;
switch biasMode
  case 1, % No biases
    biasConnect = false(numLayers,1);
  case 2, % All biases
    biasConnect = true(numLayers,1);
  case 3, % Random biases
    biasConnect = rand(numLayers,1) > 0.5;
end

% Output Connect
outputMode = floor(4*rand)+1;
switch outputMode
  case 1, % Last layer is output
    outputConnect = false(1,numLayers);
    outputConnect(numLayers) = true;
  case 2, % All outputs
    outputConnect = true(1,numLayers);
  case 3, % One output
    oc = rand(1,numLayers);
    outputConnect = (oc == max(oc));
  case 4, % Random outputs
    outputConnect = (rand(1,numLayers) > 0.7);
end

% Zero-Delay Layer Connect
zeroDelayMode = floor(3*rand)+1;
switch zeroDelayMode
  case 1, % Feedforward
    layerConnect = false(numLayers,numLayers);
    for i=2:numLayers
      layerConnect(i,i-1) = true;
    end
  case 2, % Random forward
    layerConnect = ((tril(ones(numLayers))-eye(numLayers)).*rand(numLayers)) > 0.7;
  case 3, % Cascade forward
    layerConnect = logical(tril(ones(numLayers))-eye(numLayers));
end

% Static/Dynamic
dynamicMode = enableDynamic;
if dynamicMode
  inputDelayMode = rand > 0.8;
  layerForwardDelayMode = rand > 0.8;
  layerRecurrentDelayMode = rand > 0.8;
  layerFeedbackDelayMode = rand > 0.8;
else
  inputDelayMode = false;
  layerForwardDelayMode = false;
  layerRecurrentDelayMode = false;
  layerFeedbackDelayMode = false;
end

% Delay Presence
delayPresence = min(1,0.5+rand);

% Input Delays
maxInputDelay = 0;
inputDelays = cell(numLayers,numInputs);
for i=1:numel(inputDelays), inputDelays{i} = 0; end
if inputDelayMode
  for i=1:find(inputConnect)
    if rand < delayPresence
      n = 1 + floor(rand*3);
      fcn = nntest.rand_choice(fcns.forwardDelayFcns);
      delays = fcn(n);
      maxInputDelay = max(maxInputDelay,max(delays));
      inputDelays{i} = delays;
    end
  end
end

% Layer Forward Delays
maxLayerDelay = 0;
layerDelays = cell(numLayers,numLayers);
for i=1:numel(layerDelays), layerDelays{i} = 0; end
if layerForwardDelayMode
  for i=1:find(layerConnect)
    if rand < delayPresence
      n = 1 + floor(rand*3);
      fcn = nntest.rand_choice(fcns.forwardDelayFcns);
      delays = fcn(n);
      maxLayerDelay = max(maxLayerDelay,max(delays));
      layerDelays{i} = delays;
    end
  end
end

% Layer Recurrent Delays
if layerRecurrentDelayMode
  for i=1:numLayers
    if rand < delayPresence
      layerConnect(i,i) = true;
      n = 1 + floor(rand*3);
      fcn = nntest.rand_choice(fcns.feedbackDelayFcns);
      delays = fcn(n);
      maxLayerDelay = max(maxLayerDelay,max(delays));
      layerDelays{i,i} = delays;
    end
  end
end

% Layer Feedback Delays
if layerFeedbackDelayMode
  feedbackConnect = triu(ones(numLayers))-eye(numLayers);
  for i=1:find(feedbackConnect)
    if rand < delayPresence
      layerConnect(i) = true;
      n = 1 + floor(rand*3);
      fcn = nntest.rand_choice(fcns.feedbackDelayFcns);
      delays = fcn(n);
      maxLayerDelay = max(maxLayerDelay,max(delays));
      layerDelays{i} = delays;
    end
  end
end

% Layer Order Mode
layerOrderMode = floor(rand*2)+1;
switch layerOrderMode
  case 1, % Natural
    layerOrder = 1:numLayers;
  case 2, % Random
    layerOrder = randperm(numLayers);
end
inputConnect = inputConnect(layerOrder,:);
inputDelays = inputDelays(layerOrder,:);
biasConnect = biasConnect(layerOrder);
layerConnect = layerConnect(layerOrder,:);
layerConnect = layerConnect(:,layerOrder);
layerDelays = layerDelays(layerOrder,:);
layerDelays = layerDelays(:,layerOrder);

% Network
net = network;
net.numInputs = numInputs;
net.numLayers = numLayers;
net.biasConnect = biasConnect;
net.inputConnect = inputConnect;
net.layerConnect = layerConnect;
net.outputConnect = outputConnect;
for i=1:numLayers
  for j=1:numInputs
    if inputConnect(i,j)
      net.inputWeights{i,j}.delays = inputDelays{i,j};
    end
  end
  for j=1:numLayers
    if layerConnect(i,j)
      net.layerWeights{i,j}.delays = layerDelays{i,j};
    end
  end
end

% Input Processing Functions
numFcns = length(simFcns.inputProcessFcns);
for i=1:numInputs
  n = floor(rand*numFcns)+1;
  order = randperm(numFcns);
  net.inputs{i}.processFcns = simFcns.inputProcessFcns(order(1:n))';
end

% Bias Functions
for i=1:numLayers
  if biasConnect(i)
    net.biases{i}.initFcn = 'rands';
  end
end

% Net Input Functions
for i=1:numLayers
  fcn = nntest.rand_choice(simFcns.netInputFcns);
  net.layers{i}.netInputFcn = fcn;
end

% Transfer Functions
for i=1:numLayers
  fcn = nntest.rand_choice(simFcns.transferFcns);
  net.layers{i}.transferFcn = fcn;
end

% Layer Initialization Functions
for i=1:numLayers
  fcn = nntest.rand_choice(fcns.initLayerFcns);
  net.layers{i}.initFcn = fcn;
end

% Output Processing Functions
numFcns = length(simFcns.outputProcessFcns);
for i=find(outputConnect)
  n = floor(rand*numFcns)+1;
  order = randperm(numFcns);
  net.outputs{i}.processFcns = simFcns.outputProcessFcns(order(1:n))';
end

% Sizes
inputSizes = floor(rand(1,numInputs)*5+0.75);
layerSizes = floor(rand(1,numLayers)*5+0.75);
for i=1:numInputs
  net.inputs{i}.size = inputSizes(i);
end
for i=1:numLayers
  net.layers{i}.size = layerSizes(i);
end

% Weight Functions
% Set these after input and layer sizes have been set and updated
% for input and output processing functions so that special size
% requirements can be ensured.
% SCALPROD requires source size = sink size
% CONFWF requires source size >= sink size
% These functions are not used as input weights or for layers associated
% with outputs as configuration may cause failures.
for i=1:numLayers
  S = net.layers{i}.size;
  for j=1:numInputs
    if inputConnect(i,j)
      R = net.inputs{j}.processedSize * length(net.inputWeights{i,j}.delays);
      fcn = nntest.rand_choice(simFcns.weightFcns);
      wfok = false;
      while ~wfok
        fcn = nntest.rand_choice(simFcns.weightFcns);
        wfok = true;
        % Restrict SCALPROD, CONVWF to not be input weights
        % to avoid problems with input processing changing input size
        if strcmp(fcn,'scalprod') || strcmp(fcn,'convwf')
          wfok = false;
        end
      end
      net.inputWeights{i,j}.weightFcn = fcn;
      net.inputWeights{i,j}.initFcn = 'rands';
    end
  end
  for j=1:numLayers
    if layerConnect(i,j)
      R = net.layers{j}.size * length(net.layerWeights{i,j}.delays);
      wfok = false;
      while ~wfok
        fcn = nntest.rand_choice(simFcns.weightFcns);
        wfok = true;
        % Restrict SCALPROD to R == S, and neither layer is an output to
        % avoid problems with output processing changing layer sizes
        if strcmp(fcn,'scalprod') && ((R ~= S) || net.outputConnect(i) || net.outputConnect(j))
          wfok = false;
        end
        % CONVWF requires R < S, and neither layer is an output to
        % avoid problems with output processing changing layer sizes
        if strcmp(fcn,'convwf') && ((R < S) || (S == 0) ...
            || net.outputConnect(i) || net.outputConnect(j) || net.outputConnect(j))
          wfok = false;
        end
      end
      net.layerWeights{i,j}.weightFcn = fcn;
      net.layerWeights{i,j}.initFcn = 'rands';
    end
  end
end

% Learning
for i=1:net.numLayers
  if net.biasConnect
    net.biases{i}.learn = (rand > 0.1);
  end
  for j=1:net.numInputs
    if net.inputConnect(i,j)
      net.inputWeights{i,j}.learn = (rand > 0.1);
    end
  end
  for j=1:net.numLayers
    if net.layerConnect(i,j)
      net.layerWeights{i,j}.learn = (rand > 0.1);
    end
  end
end

% Performance Function
fcn = nntest.rand_choice(simFcns.performFcns);
net.performFcn = fcn;

% Performance Normalization
switch ceil(rand*3)
  case 1, net.performParam.normalization = 'none';
  case 2, net.performParam.normalization = 'standard';
  case 3, net.performParam.normalization = 'percent';
end

% Performance Regularization
net.performParam.regularization = (rand < 0.5)*(rand*0.8+0.1);

% Name
net.name = ['nntest.rand_net(' num2str(seed) ')'];
for i=1:net.numInputs
  net.inputs{i}.name = ['x' num2str(i)];
end
for i=1:net.numLayers
  net.layers{i}.name = ['Layer ' num2str(i)];
end
for i=1:net.numOutputs
  ii = find(cumsum(net.outputConnect)==i,1);
  net.outputs{ii}.name = ['y' num2str(ii)];
end

% Efficiency
net.efficiency.flattenTime = (rand < 0.5);
