function hints = wb_indices(net,hints,allWeights)
%NN.WB_INDICES

memAlign = 32;

if nargin < 2, hints = struct; end
if nargin < 3, allWeights = false; end

hints.bInclude = false(net.numLayers,1);
hints.iwInclude = false(net.numLayers,net.numInputs);
hints.lwInclude = false(net.numLayers,net.numLayers);
hints.bPos = zeros(net.numLayers,1);
hints.iwPos = zeros(net.numLayers,net.numInputs);
hints.lwPos = zeros(net.numLayers,net.numLayers);
hints.bInd = cell(net.numLayers,1);
hints.iwInd = cell(net.numLayers,net.numInputs);
hints.lwInd = cell(net.numLayers,net.numLayers);

wbLen = 0;
for i=1:net.numLayers
  
  % Biases
  if net.biasConnect(i) && (net.biases{i}.learn || allWeights)
    wbLen = ceil(wbLen/memAlign)*memAlign; % Move to next memory segment

    hints.bInclude(i) = true;
    hints.bPos(i) = wbLen + 1;
    hints.bInd{i} = wbLen + (1:numel(net.b{i}));
    wbLen = wbLen + numel(net.b{i});
  end

  % Input Weights
  for j=1:net.numInputs
    if net.inputConnect(i,j) && (net.inputWeights{i,j}.learn || allWeights)
      wbLen = ceil(wbLen/memAlign)*memAlign; % Move to next memory segment
      
      % Standard Weight Order
      numWeights = numel(net.IW{i,j});
      ind = 1:numWeights;
      
      % Reverse Delay Order
      numDelays = length(net.inputWeights{i,j}.delays);
      numWeightsPerStep = numWeights/numDelays;
      ind = reshape(fliplr(reshape(ind,numWeightsPerStep,numDelays)),1,numWeights);
      
      hints.iwInclude(i,j) = true;
      hints.iwPos(i,j) = wbLen + 1;
      hints.iwInd{i,j} = wbLen + ind;
      wbLen = wbLen + numWeights;
    end
  end

  % Layer Weights
  for j=1:net.numLayers
    if net.layerConnect(i,j) && (net.layerWeights{i,j}.learn || allWeights)
      wbLen = ceil(wbLen/memAlign)*memAlign; % Move to next memory segment
      
      % Standard Weight Order
      numWeights = numel(net.LW{i,j});
      ind = 1:numWeights;
      
      % Reverse Delay Order
      numDelays = length(net.layerWeights{i,j}.delays);
      numWeightsPerStep = numWeights/numDelays;
      ind = reshape(fliplr(reshape(ind,numWeightsPerStep,numDelays)),1,numWeights);
      
      hints.lwInclude(i,j) = true;
      hints.lwPos(i,j) = wbLen + 1;
      hints.lwInd{i,j} = wbLen + ind;
      wbLen = wbLen + numWeights;
    end
  end
end

wbLen = ceil(wbLen/memAlign)*memAlign; % Move to next memory segment
hints.wbLen = wbLen;
