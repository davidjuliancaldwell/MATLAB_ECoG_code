function hints = netHints(net,hints)

% Copyright 2012 The MathWorks, Inc.

net = struct(net);

% Dimensions
hints.numInputs = net.numInputs;
hints.numLayers = net.numLayers;
hints.numOutputs = net.numOutputs;

% Inputs
for i=1:net.numInputs
  % Processing
  processFcns = net.inputs{i}.processFcns;
  processSettings = net.inputs{i}.processSettings;
  for j=length(processFcns):-1:1
    if processSettings{j}.no_change
      processFcns(j) = [];
      processSettings(j) = [];
    end
  end
  hints.numInpProc(i) = length(processFcns);
  if (hints.numInpProc(i) > 0)
    for j=1:hints.numInpProc(i)
      hints.inp(i).procApply{j} = str2func([processFcns{j} '.apply']);
      hints.inp(i).procRev{j} = str2func([processFcns{j} '.reverse']);
      hints.inp(i).procBP{j} = str2func([processFcns{j} '.backprop']);
      hints.inp(i).procFP{j} = str2func([processFcns{j} '.forwardprop']);
      hints.inp(i).procBPrev{j} = str2func([processFcns{j} '.backpropReverse']);
      hints.inp(i).procFPrev{j} = str2func([processFcns{j} '.forwardpropReverse']);
      hints.inp(i).procSet{j} = processSettings{j};
      hints.inp(i).procMapminmax(j) = strcmp(processFcns{j},'mapminmax');
    end
  end
end
hints.inputSizes = nn.input_sizes(net);
hints.numInputElements = sum(hints.inputSizes);

% Layers
hints.layerOrder  = nn.layer_order(net);
hints.layerOrderReverse = fliplr(hints.layerOrder);
hints.layer2Output = cumsum(net.outputConnect);
hints.output2Layer = find(net.outputConnect);

for i=1:net.numLayers
  % Net Input
  hints.netApply{i} = str2func([net.layers{i}.netInputFcn '.apply']);
  hints.netBP{i} = str2func([net.layers{i}.netInputFcn '.backprop']);
  hints.netFP{i} = str2func([net.layers{i}.netInputFcn '.forwardprop']);
  hints.netParam{i} = net.layers{i}.netInputParam;
  hints.netNetsum(i) = strcmp(net.layers{i}.netInputFcn,'netsum');
  % Transfer
  hints.tfApply{i} = str2func([net.layers{i}.transferFcn '.apply']);
  hints.tfBP{i} = str2func([net.layers{i}.transferFcn '.backprop']);
  hints.tfFP{i} = str2func([net.layers{i}.transferFcn '.forwardprop']);
  hints.tfParam{i} = net.layers{i}.transferParam;
  hints.tfPurelin(i) = strcmp(net.layers{i}.transferFcn,'purelin');
  hints.tfTansig(i) = strcmp(net.layers{i}.transferFcn,'tansig');
end
hints.layerSizes = nn.layer_sizes(net);
hints.numLayerElements = sum(hints.layerSizes);

% Outputs
hints.outputSizes = nn.output_sizes(net);
hints.numOutputElements = sum(hints.outputSizes);
hints.outputElementInd = cell(1,net.numOutputs);

hints.numOutProc = [];
for i=1:net.numOutputs
  % Processing
  ii = hints.output2Layer(i);
  hints.outInd{i} = sum(hints.outputSizes(1:(i-1))) + (1:hints.outputSizes(i));
  if isempty(net.performFcn) || ~isfield(net.performParam,'normalization')
    normalization = 'none';
  else
    normalization = net.performParam.normalization;
  end
  switch (normalization)
    case 'standard'
      hints.errNorm{i} = 2 ./ (net.outputs{ii}.range(:,2)-net.outputs{ii}.range(:,1));
    case 'percent'
      hints.errNorm{i} = 1 ./ (net.outputs{ii}.range(:,2)-net.outputs{ii}.range(:,1));
    otherwise
      hints.errNorm{i} = ones(net.outputs{ii}.size,1);
  end
  hints.errNorm{i}(~isfinite(hints.errNorm{i})) = 1;
  hints.doErrNorm(i) = any(hints.errNorm{i} ~= 1);
  processFcns = net.outputs{ii}.processFcns;
  processSettings = net.outputs{ii}.processSettings;
  for j=length(processFcns):-1:1
    if processSettings{j}.no_change
      processFcns(j) = [];
      processSettings(j) = [];
    end
  end
  hints.numOutProc(i) = length(processFcns);
  if (hints.numOutProc(i) > 0)
    for j=1:hints.numOutProc(i)
      hints.out(i).procApply{j} = str2func([processFcns{j} '.apply']);
      hints.out(i).procRev{j} = str2func([processFcns{j} '.reverse']);
      hints.out(i).procBP{j} = str2func([processFcns{j} '.backprop']);
      hints.out(i).procFP{j} = str2func([processFcns{j} '.forwardprop']);
      hints.out(i).procBPrev{j} = str2func([processFcns{j} '.backpropReverse']);
      hints.out(i).procFPrev{j} = str2func([processFcns{j} '.forwardpropReverse']);
      hints.out(i).procSet{j} = processSettings{j};
      hints.out(i).procMapminmax(j) = strcmp(processFcns{j},'mapminmax');
    end
  end
end
hints.maxOutProc = max([0 hints.numOutProc(i)]);

% Weights and Biases
hints.numZ = [];
for i=1:net.numLayers
  zInd = 0;
  
  % Biases
  if net.biasConnect(i)
    zInd = zInd + 1;
    hints.bInclude(i) = net.biases{i}.learn;
  end

  % Input Weights
  for j=1:net.numInputs
    if net.inputConnect(i,j)
      zInd = zInd + 1;
      hints.iwzInd(i,j) = zInd;
      hints.iwApply{i,j} = str2func([net.inputWeights{i,j}.weightFcn '.apply']);
      hints.iwBP{i,j} = str2func([net.inputWeights{i,j}.weightFcn '.backprop']);
      hints.iwFP{i,j} = str2func([net.inputWeights{i,j}.weightFcn '.forwardprop']);
      hints.iwBS{i,j} = str2func([net.inputWeights{i,j}.weightFcn '.backstop']);
      hints.iwBSP{i,j} = str2func([net.inputWeights{i,j}.weightFcn '.backstopParallel']);
      hints.iwFS{i,j} = str2func([net.inputWeights{i,j}.weightFcn '.forwardstart']);
      hints.iwParam{i,j} = net.inputWeights{i,j}.weightParam;
      hints.iwInclude(i,j) = net.inputWeights{i,j}.learn;
      hints.iwUnitDelay(i,j) = (numel(net.inputWeights{i,j}.delays)==1) && (net.inputWeights{i,j}.delays==0);
      hints.iwDotprod(i,j) = strcmp(net.inputWeights{i,j}.weightFcn,'dotprod');
    end
  end

  % Layer Weights
  for j=1:net.numLayers
    if net.layerConnect(i,j)
      zInd = zInd + 1;
      hints.lwzInd(i,j) = zInd;
      hints.lwApply{i,j} = str2func([net.layerWeights{i,j}.weightFcn '.apply']);
      hints.lwBP{i,j} = str2func([net.layerWeights{i,j}.weightFcn '.backprop']);
      hints.lwFP{i,j} = str2func([net.layerWeights{i,j}.weightFcn '.forwardprop']);
      hints.lwBS{i,j} = str2func([net.layerWeights{i,j}.weightFcn '.backstop']);
      hints.lwBSP{i,j} = str2func([net.layerWeights{i,j}.weightFcn '.backstopParallel']);
      hints.lwFS{i,j} = str2func([net.layerWeights{i,j}.weightFcn '.forwardstart']);
      hints.lwParam{i,j} = net.layerWeights{i,j}.weightParam;
      hints.lwInclude(i,j) = net.layerWeights{i,j}.learn;
      hints.lwUnitDelay(i,j) = (numel(net.layerWeights{i,j}.delays)==1) && (net.layerWeights{i,j}.delays==0);
      hints.lwDotprod(i,j) = strcmp(net.layerWeights{i,j}.weightFcn,'dotprod');
    end
  end
  
  hints.numZ(i) = zInd;
end
hints.maxZ = max(hints.numZ);

% Performance
if isempty(net.performFcn)
  hints.hasPerf = false;
  hints.perfNorm = false;
else
  hints.hasPerf = true;
  hints.perfApply = str2func([net.performFcn '.apply']);
  hints.perfNorm = feval([net.performFcn '.normalize']);
  hints.perfBP = str2func([net.performFcn '.backprop']);
  hints.perfFP = str2func([net.performFcn '.forwardprop']);
  hints.perfParam = net.performParam;
  hints.perfMSE = strcmp(net.performFcn,'mse');
end

% Additional Hints
hints = nn.wb_indices(net,hints);
