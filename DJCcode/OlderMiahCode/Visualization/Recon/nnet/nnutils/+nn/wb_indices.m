function hints = wb_indices(net,hints,allWeights)
%NN.WB_INDICES

% Copyright 2012 The MathWorks, Inc.

% Flag = true ==> include all weights

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
    hints.bInclude(i) = true;
    hints.bPos(i) = wbLen + 1;
    hints.bInd{i} = wbLen + (1:numel(net.b{i}));
    wbLen = wbLen + numel(net.b{i});
  end

  % Input Weights
  for j=1:net.numInputs
    if net.inputConnect(i,j) && (net.inputWeights{i,j}.learn || allWeights)
      hints.iwInclude(i,j) = true;
      hints.iwPos(i,j) = wbLen + 1;
      hints.iwInd{i,j} = wbLen + (1:numel(net.IW{i,j}));
      wbLen = wbLen + numel(net.IW{i,j});
    end
  end

  % Layer Weights
  for j=1:net.numLayers
    if net.layerConnect(i,j) && (net.layerWeights{i,j}.learn || allWeights)
      hints.lwInclude(i,j) = true;
      hints.lwPos(i,j) = wbLen + 1;
      hints.lwInd{i,j} = wbLen + (1:numel(net.LW{i,j}));
      wbLen = wbLen + numel(net.LW{i,j});
    end
  end
end

hints.wbLen = wbLen;
