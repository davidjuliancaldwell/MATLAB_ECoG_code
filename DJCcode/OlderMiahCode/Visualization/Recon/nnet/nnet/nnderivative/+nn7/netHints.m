function hints = netHints(net,hints)

% Copyright 2010-2012 The MathWorks, Inc.

% INPUTS
% inputSizes{i}
% totalInputSize
hints.inputSizes = zeros(net.numInputs,1);
for i=1:net.numInputs
  hints.inputSizes(i) = net.inputs{i}.size;
end
hints.totalInputSize = sum(hints.inputSizes);

% LAYERS
% layerSizes{i}
% totalLayerSize
hints.layerSizes = zeros(net.numLayers,1);
for i=1:net.numLayers
  hints.layerSizes(i) = net.layers{i}.size;
end
hints.totalLayerSize = sum(hints.layerSizes);

% INDEX CONVERSION
% output2layer
% layer2output
hints.output2layer = find(net.outputConnect);
hints.layer2output = cumsum(net.outputConnect) .* net.outputConnect;

% OUTPUTS
% outputInd (same as output2layer)
% outputSizes{i}
% totalOutputSize
% processedOutputSizes(i)
% totalProcessedOutputSize
hints.numOutProc = [];
hints.outputInd = find(net.outputConnect);
hints.outputSizes = zeros(net.numOutputs,1);
hints.numOutProc = zeros(net.numOutputs,1);
hints.processedOutputSizes = zeros(net.numOutputs,1);
for i=1:net.numOutputs
  hints.outputSizes(i) = net.outputs{hints.outputInd(i)}.size;
  hints.processedOutputSizes(i) = net.outputs{hints.outputInd(i)}.processedSize;
  hints.numOutProc(i) = length(net.outputs{hints.outputInd(i)}.processFcns);
end
hints.totalOutputSize = sum(hints.outputSizes);
hints.totalProcessedOutputSize = sum(hints.processedOutputSizes);
hints.maxOutProc = max([0 hints.numOutProc(i)]);

% CONNECTIONS
% inputConnectFrom{i}
% inputConnectTo{i}
% layerConnectFrom{i}
% layerConnectTo{i}
hints.inputConnectFrom = cell(net.numLayers,1);
for i=1:net.numLayers
  hints.inputConnectFrom{i} = find(net.inputConnect(i,:));
end
hints.inputConnectTo = cell(net.numInputs,1);
for i=1:net.numInputs
  hints.inputConnectTo{i} = find(net.inputConnect(:,i)');
end
hints.layerConnectFrom = cell(net.numLayers,1);
hints.layerConnectTo = cell(net.numLayers,1);
for i=1:net.numLayers
  hints.layerConnectFrom{i} = find(net.layerConnect(i,:));
  hints.layerConnectTo{i} = find(net.layerConnect(:,i)');
end

% LAYER ORDERS & ERROR CONDITIONS
% simLayerOrder
% bpLayerOrder
% zeroDelay (ERROR: indicates network has zero delay loop)
% noWeights (WARNING: indicates layer with no weights)
[hints.simLayerOrder,hints.zeroDelay] = simlayorder(net);
hints.bpLayerOrder=fliplr(hints.simLayerOrder);
hints.noWeights = find(~any([net.inputConnect net.layerConnect],2));

% DELAYS
% inputDelays{i,j}
% inputConnectOnlyZeroDay{i,j}
% inputConnectWithZeroDelay{i,j}
% layerDelays{i,j}
% layerConnectOZD{i,j}
% layerConnectWZD{i,j}
% layerConnectToOZD
% layerConnectToWZD
hints.inputDelays = cell(net.numLayers,net.numLayers);
hints.inputConnectOnlyZeroDay = false(net.numLayers,net.numLayers);
hints.inputConnectWithZeroDelay = false(net.numLayers,net.numLayers);
for i=1:net.numLayers
  for j=hints.inputConnectFrom{i}
    delays = net.inputWeights{i,j}.delays;
    hints.inputDelays{i,j} = delays;
    hints.inputConnectOnlyZeroDay(i,j) = ~isempty(delays) && all(delays==0);
    hints.inputConnectWithZeroDelay(i,j) = ~isempty(delays) && any(delays==0) && ~all(delays==0);
  end
end
hints.layerDelays = cell(net.numLayers,net.numLayers);
hints.layerConnectOZD = false(net.numLayers,net.numLayers);
hints.layerConnectWZD = false(net.numLayers,net.numLayers);
for i=1:net.numLayers
  for j=hints.layerConnectFrom{i}
    delays = net.layerWeights{i,j}.delays;
    hints.layerDelays{i,j} = delays;
    hints.layerConnectOZD(i,j) = ~isempty(delays) && all(delays == 0);
    hints.layerConnectWZD(i,j) = ~isempty(delays) && any(delays == 0) && ~all(delays == 0);
  end
end
hints.layerConnectToZD = cell(1,net.numLayers);
hints.layerConnectToWZD = cell(1,net.numLayers);
for i=1:net.numLayers
  hints.layerConnectToOZD{i} = find(hints.layerConnectOZD(:,i)');
  hints.layerConnectToWZD{i} = find(hints.layerConnectWZD(:,i)');
end

% SIMULATION FUNCTIONS
% inputProcessingFcn
% inputProcessingParam
% inputWeightFcn
% layerWeightFcn
% netInputFcn
% transferFcn
% outputProcessingFcn
hints.inputWeightFcn = cell(net.numLayers,net.numInputs);
hints.layerWeightFcn = cell(net.numLayers,net.numInputs);
hints.dLayerWeightFcn = hints.layerWeightFcn;
hints.netInputFcn = cell(net.numLayers,1);
hints.transferFcn = cell(net.numLayers,1);
for i=1:net.numLayers
  for j=hints.inputConnectFrom{i}
    hints.inputWeightFcn{i,j} = str2func(net.inputWeights{i,j}.weightFcn);
  end
  for j=hints.layerConnectFrom{i}
    hints.layerWeightFcn{i,j} = str2func(net.layerWeights{i,j}.weightFcn);
  end
  hints.netInputFcn{i} = str2func(net.layers{i}.netInputFcn);
  hints.transferFcn{i} = str2func(net.layers{i}.transferFcn);
end

% WEIGHT & BIASES COLUMNS
% =======================
hints.inputWeightCols = zeros(net.numLayers,net.numInputs);
hints.layerWeightCols = zeros(net.numLayers,net.numLayers);
for i=1:net.numLayers
  for j=find(net.inputConnect(i,:))  
    hints.inputWeightCols(i,j) = net.inputWeights{i,j}.size(2);
  end
  for j=find(net.layerConnect(i,:)) 
    hints.layerWeightCols(i,j) = net.layerWeights{i,j}.size(2);
  end
end

% WEIGHT & BIASES LEARNING
% ========================

% inputLearn, layerLearn, biasLearn
hints.inputLearn = net.inputConnect;
hints.layerLearn = net.layerConnect;
hints.biasLearn = net.biasConnect;
for i=1:net.numLayers
  for j=find(net.inputConnect(i,:))
    hints.inputLearn(i,j) = net.inputWeights{i,j}.learn;
  end
  for j=find(net.layerConnect(i,:))
    hints.layerLearn(i,j) = net.layerWeights{i,j}.learn;
  end
  if (net.biasConnect(i))
    hints.biasLearn(i) = net.biases{i}.learn;
  end
end

% inputLearnFrom, layerLearnFrom
hints.inputLearnFrom = cell(net.numLayers,1);
for i=1:net.numLayers
  hints.inputLearnFrom{i} = find(hints.inputLearn(i,:));
end
hints.layerLearnFrom = cell(net.numLayers,1);
for i=1:net.numLayers
  hints.layerLearnFrom{i} = find(hints.layerLearn(i,:));
end

% WEIGHT & BIAS INDICES INTO X VECTOR
% ===================================
hints.inputWeightInd = cell(net.numLayers,net.numInputs);
hints.layerWeightInd = cell(net.numLayers,net.numLayers);
hints.biasInd = cell(1,net.numLayers);
hints.xLen = 0;
for i=1:net.numLayers
  if (hints.biasLearn(i))
    len = net.layers{i}.size;
    hints.biasInd{i} = hints.xLen + (1:len);
    hints.xLen = hints.xLen + len;
  end
  for j=find(hints.inputLearn(i,:))
    cols = net.inputWeights{i,j}.size(2);
    len = net.inputWeights{i,j}.size(1) * cols;
    hints.inputWeightInd{i,j} = hints.xLen + (1:len);
    hints.xLen = hints.xLen + len;
  end
  for j=find(hints.layerLearn(i,:))
    cols = net.layerWeights{i,j}.size(2);
    len = net.layerWeights{i,j}.size(1) * cols;
    hints.layerWeightInd{i,j} = hints.xLen + (1:len);
    hints.xLen = hints.xLen + len;
  end
end


% Input Processing Fcn/Param
hints.inputProcessSteps = zeros(1,net.numInputs);
hints.inputProcessFcns = cell(1,net.numInputs);
hints.processSettings = cell(1,net.numInputs);
for i = 1:net.numInputs
  pf = net.inputs{i}.processFcns;
  ps = net.inputs{i}.processSettings;
  numSteps = length(ps);
  keep = true(1,numSteps);
  for j=1:numSteps
    keep(j) = ~ps{j}.no_change;
  end
  hints.inputProcessSteps(i) = sum(keep);
  hints.inputProcessFcns{i} = pf(keep);
  hints.processSettings{i} = ps(keep);
end

% Output Processing
hints.outputProcessSteps = zeros(1,net.numOutputs);
hints.outputProcessFcns = cell(1,net.numOutputs);
hints.processSettings = cell(1,net.numOutputs);
for i = 1:net.numOutputs
  ii = hints.output2layer(i);
  pf = net.outputs{ii}.processFcns;
  ps = net.outputs{ii}.processSettings;
  numSteps = length(ps);
  keep = true(1,numSteps);
  for j=1:numSteps
    keep(j) = ~ps{j}.no_change;
  end
  hints.outputProcessSteps(i) = sum(keep);
  hints.outputProcessFcns{i} = fliplr(pf(keep));
  hints.processSettings{i} = fliplr(ps(keep));
end

% Net Input Arguments
for i=1:net.numLayers
  hints.numZ(i) = sum([net.inputConnect(i,:) net.layerConnect(i,:) net.biasConnect(i)]);
end
hints.maxZ = max(hints.numZ);

% Number of Processing Functions
for i=1:net.numInputs
  processFcns = net.inputs{i}.processFcns;
  hints.numInpProc(i) = length(processFcns);
end
hints.output2Layer = find(net.outputConnect);
for i=1:net.numOutputs
  ii = hints.output2Layer(i);
  processFcns = net.outputs{ii}.processFcns;
  hints.numOutProc(i) = length(processFcns);
end
% ============== WAS NN.SUBFCNS ===============

% Dimensions
hints.numInputs = net.numInputs;
hints.numLayers = net.numLayers;
hints.numOutputs = net.numOutputs;

% Inputs
for i=1:net.numInputs
  input = [];
  
  % Processing
  num = length(net.inputs{i}.processFcns);
  if (num > 0)
    for j=1:num
      f = net.inputs{i}.processFcns{j};
      sf = nnModuleInfo(f);
      sf.settings = net.inputs{i}.processSettings{j};
      input.process(j) = sf;
    end
  else
    input.process = [];
  end
  hints.inputs(i) = input;
  
end

% Layers
for i=1:net.numLayers
  
  % Net Input
  f = net.layers{i}.netInputFcn;
  sf = nnModuleInfo(f);
  sf.param = net.layers{i}.netInputParam;
  hints.layers(i).netInput = sf;
  
  % Transfer
  f = net.layers{i}.transferFcn;
  sf = nnModuleInfo(f);
  sf.param = net.layers{i}.transferParam;
  hints.layers(i).transfer = sf;
  
end

% Outputs
output2layer = find(net.outputConnect);
for ii=1:net.numOutputs
  i = output2layer(ii);
  output = [];
  
  % Processing
  num = length(net.outputs{i}.processFcns);
  if (num > 0)
    for j=1:num
      f = net.outputs{i}.processFcns{j};
      sf = nnModuleInfo(f);
      sf.settings = net.outputs{i}.processSettings{j};
      output.process(j) = sf;
    end
  else
    output.process = [];
  end
  hints.outputs(ii) = output;
  
end

% Biases
for i=1:net.numLayers
  if net.biasConnect(i)
    
    % Learn
    if ~isdeployed
      f = net.biases{i}.learnFcn;
      if ~isempty(f)
        sf = struct(feval(f,'subfunctions'));
        sf.param = net.biases{i}.learnParam;
        sf.exist = true;
      else
        sf = struct;
        sf.exist = false;
      end
      hints.biases(i).learn = sf;
    end
    
  end
end

% Input Weights
for i=1:net.numLayers
  for j=1:net.numInputs
    if net.inputConnect(i,j)
      
      % Weight
      f = net.inputWeights{i,j}.weightFcn;
      sf = nnModuleInfo(f);
      sf.param = net.inputWeights{i,j}.weightParam;
      hints.inputWeights(i,j).weight = sf;
      
      % Learn
      if ~isdeployed
        f = net.inputWeights{i,j}.learnFcn;
        if ~isempty(f)
          sf = feval(f,'subfunctions');
          sf.param = net.inputWeights{i,j}.learnParam;
          sf.exist = true;
        else
          sf = struct;
          sf.exist = false;
        end
        hints.inputWeights(i,j).learn = sf;
      end
      
    end
  end
end

% Layer Weights
for i=1:net.numLayers
  for j=1:net.numLayers
    if net.layerConnect(i,j)
      
      % Weight
      f = net.layerWeights{i,j}.weightFcn;
      sf = nnModuleInfo(f);
      sf.param = net.layerWeights{i,j}.weightParam;
      hints.layerWeights(i,j).weight = sf;
      
      % Learn
      if ~isdeployed
        f = net.layerWeights{i,j}.learnFcn;
        if ~isempty(f)
          sf = feval(f,'subfunctions');
          sf.param = net.layerWeights{i,j}.learnParam;
          sf.exist = true;
        else
          sf = struct;
          sf.exist = false;
        end
        hints.layerWeights(i,j).learn = sf;
      end
      
    end
  end
end

% Derivatives
if ~isdeployed
  hints.deriv = feval(net.derivFcn,'subfunctions');
end

% Performance
hints.perform.exist = ~isempty(net.performFcn);
if hints.perform.exist
  hints.perform = nnModuleInfo(net.performFcn);
  hints.perform.param = net.performParam;
  hints.perfNorm = feval([net.performFcn '.normalize']);
else
  hints.perform = [];
  hints.perform.param = struct;
end

% Additional Hints
hints = nn.wb_indices(net,hints);

% ===========================================================
function [order,zeroDelay]=simlayorder(net)
%SIMLAYORDER Order to simulate layers in.

% INITIALIZATION
order = zeros(1,net.numLayers);
unordered = ones(1,net.numLayers);

% FIND ZERO-DELAY CONNECTIONS BETWEEN LAYERS
dependancies = zeros(net.numLayers,net.numLayers);
for i=1:net.numLayers
  for j=find(net.layerConnect(i,:))
    if any(net.layerWeights{i,j}.delays == 0)
      dependancies(i,j) = 1;
    end
  end
end

% FIND LAYER ORDER
for k=1:net.numLayers
  for i=find(unordered)
    if ~any(dependancies(i,:))
      dependancies(:,i) = 0;
      order(k) = i;
      unordered(i) = 0;
      break;
    end
  end
end

% CHECK THAT ALL LAYERS WERE ORDERED
zeroDelay = any(unordered);
