function hints = netHints(net,hints)

% Copyright 2012 The MathWorks, Inc.

% DO NOT CHANGE THE ORDER OF THESE FUNCTION LISTS!
% These lists are used to assign indices to the functions.
% New functions should be appended, not inserted.

preprocessFcns = {
  'fixunknowns'
  'mapminmax'
  'mapstd'
  'processpca'
  'removeconstantrows'
  'removerows'
  'lvqoutputs'
  };

weightFcns = {
  'convwf'
  'dotprod'
  'negdist'
  'normprod'
  'scalprod'
  'boxdist'
  'dist'
  'linkdist'
  'mandist'
  };

netInputFcns = {
  'netsum'
  'netprod'
  };

transferFcns = {
  'compet'
  'hardlim'
  'hardlims'
  'logsig'
  'netinv'
  'poslin'
  'purelin'
  'radbas'
  'radbasn'
  'satlin'
  'satlins'
  'softmax'
  'tansig'
  'tribas'
  'elliotsig'
  'elliot2sig'
  };

perfFcns = {
  ''
  'mae'
  'mse'
  'sae'
  'sse'
  };

layerOrder  = nn.layer_order(net);
numSimLayers = numel(layerOrder);
layer2Output = cumsum(net.outputConnect);

hints.allWB = nn.wb_indices(net,struct,true);
hints.learnWB = nn.wb_indices(net,struct,false);

processingInfoArray = [];
intHints = [];
floatHints = [];

% Input Hints
xPos = 0;
pPos = 0;
pyPos = 0;
inputs = cell(1,net.numInputs);
for i=1:net.numInputs
  xSize = net.inputs{i}.size;
  pSize = net.inputs{i}.processedSize;
  processInfoOffset = numel(processingInfoArray);
  processFcns = net.inputs{i}.processFcns;
  processSettings = net.inputs{i}.processSettings;
  for j=length(processFcns):-1:1
    if processSettings{j}.no_change
      processFcns(j) = [];
      processSettings(j) = [];
    end
  end
  
  numProc = numel(processFcns);
  for j=1:length(processFcns)
    procFcnIndex = nnstring.match(processFcns{j},preprocessFcns);
    settings = processSettings{j};
    procXSize = settings.xrows;
    procYSize = settings.yrows;
    
    procInfo = [...
      procFcnIndex ... % Processing function index
      0 ... % Unused field for inputs, used by outputs
      pyPos ...  % Forward process offset - starts at 0 for first input
      procXSize ... % X-size (pre-processed input)
      procYSize ... % Y-size (post-processed input)
      numel(floatHints) ... % Offset of double processing parameters
      numel(intHints) ... % Offset of integer processing Parameters
      ];
    
    switch processFcns{j}
      case 'fixunknowns'
        floatParam = [settings.xmeans(:)];
        intParam = [settings.shift(:); settings.unknown(:)-1];
      case 'lvqoutputs'
        floatParam = [];
        intParam = [];
      case 'mapminmax',
        floatParam = [settings.gain(:); settings.xoffset(:); settings.ymin(:)];
        intParam = [];
      case 'mapstd',
        floatParam = [settings.gain(:); settings.xoffset(:); settings.ymean(:)];
        intParam = [];
      case 'processpca'
        floatParam = [settings.transform(:); settings.inverseTransform(:)];
        intParam = [];
      case 'removeconstantrows'
        floatParam = [settings.value(:)];
        intParam = [settings.keep(:)-1; settings.remove(:)-1];
      case 'removerows'
        floatParam = [];
        intParam = [settings.keep_ind(:)-1; settings.remove_ind(:)-1];
      otherwise
        error('Unsupported processing function.');
    end
    
    processingInfoArray = [processingInfoArray procInfo];
    
    intHints = [intHints; intParam(:)];
    floatHints = [floatHints; floatParam(:)];
    
    pyPos = pyPos + settings.yrows;
  end
  
  inputs{i} = [...
    xSize ...
    xPos ...
    pSize ...
    pPos ...
    numProc ...
    processInfoOffset ...
    ];
  xPos = xPos + xSize;
  pPos = pPos + pSize;
  
end
inputs = [inputs{:}];
seriesInputProcElements = pyPos;

% Layer Hints
aPos = 0;
maxLayerZSize = 0;
maxLayerSize = 0;
layers = cell(1,net.numLayers);
for i=1:net.numLayers
  aSize = net.layers{i}.size;
  layers{i} = [ ...
    aSize ...
    aPos ...
    nnstring.match(net.layers{i}.netInputFcn,netInputFcns) ...
    nnstring.match(net.layers{i}.transferFcn,transferFcns) ...
    layer2Output(i);
    ];
  aPos = aPos + aSize;
  numWeights = sum(net.inputConnect(i,:))+sum(net.layerConnect(i,:));
  maxLayerZSize = max(maxLayerZSize,aSize * numWeights);
  maxLayerSize = max(maxLayerSize,aSize);
end
layers = [layers{:}];

% Output Hints
yPos = 0;
pPos = 0;
outputs = cell(1,net.numOutputs);
maxOutProcXElements = 0;
maxOutProcYElements = 0;
maxOutputSize = 0;
for i=1:net.numLayers
  pxPos = 0;
  pyPos = 0;
  
  if net.outputConnect(i)
    ySize = net.outputs{i}.size;
    pSize = net.outputs{i}.processedSize;
    processInfoOffset = numel(processingInfoArray);
    processFcns = net.outputs{i}.processFcns;
    processSettings = net.outputs{i}.processSettings;
    for j=length(processFcns):-1:1
      if processSettings{j}.no_change
        processFcns(j) = [];
        processSettings(j) = [];
      end
    end
    
    numProc = numel(processFcns);
    for j=1:length(processFcns)
      procFcnIndex = nnstring.match(processFcns{j},preprocessFcns);
      settings = processSettings{j};
      
      procInfo = [...
        procFcnIndex ... % Processing function index
        pxPos ... % Reverse process offset - starts at 0 for each output
        pyPos ... % Forward process offset - starts at 0 for each output
        settings.xrows ... % X-size (pre-processed input)
        settings.yrows ... % Y-size (post-processed input)
        numel(floatHints) ... % Offset of double processing parameters
        numel(intHints) ... % Offset of integer processing Parameters
        ];
    
      switch processFcns{j}
        case 'fixunknowns'
          floatParam = [settings.xmeans(:)];
          intParam = [settings.shift(:); settings.unknown(:)-1];
        case 'lvqoutputs'
          floatParam = [];
          intParam = [];
        case 'mapminmax',
          floatParam = [settings.gain(:); settings.xoffset(:); settings.ymin(:)];
          intParam = [];
        case 'mapstd',
          floatParam = [settings.gain(:); settings.xoffset(:); settings.ymean(:)];
          intParam = [];
        case 'processpca'
          floatParam = [settings.transform(:); settings.inverseTransform(:)];
          intParam = [];
        case 'removeconstantrows'
          floatParam = [settings.value(:)];
          intParam = [settings.keep(:)-1; settings.remove(:)-1];
          disp('')
        case 'removerows'
          floatParam = [];
          intParam = [settings.keep_ind(:)-1;  settings.remove_ind(:)-1];
        otherwise
          error('Unsupported processing function.');
      end

      processingInfoArray = [processingInfoArray procInfo];
      
      intHints = [intHints; intParam(:)];
      floatHints = [floatHints; floatParam(:)];
      
      pxPos = pxPos + settings.xrows;
      pyPos = pyPos + settings.yrows;
    end
    
    
    % Double Hints
    if isempty(net.performFcn) || ~isfield(net.performParam,'normalization')
      normalization = 'none';
    else
      normalization = net.performParam.normalization;
    end
    switch (normalization)
      case 'standard'
        errNorm = 2 ./ (net.outputs{i}.range(:,2)-net.outputs{i}.range(:,1));
      case 'percent'
        errNorm = 1 ./ (net.outputs{i}.range(:,2)-net.outputs{i}.range(:,1));
      otherwise
        errNorm = ones(net.outputs{i}.size,1);
    end
    errNorm(~isfinite(errNorm)) = 1;
    doErrNorm = any(errNorm ~= 1);
    
    % Combine Output Hints
    outputs{i} = [...
      1 ... % Output is connected
      sum(net.outputConnect(1:i))-1 ... % Output index
      ySize ...
      yPos ...
      pSize ...
      pPos ...
      numProc ...
      processInfoOffset ... Processing info array position
      doErrNorm ...
      numel(floatHints) ... Error normalization position
      ];
    
    floatHints = [floatHints; errNorm(:)];
    
    yPos = yPos + ySize;
    pPos = pPos + pSize;
    
    maxOutputSize = max(maxOutputSize,ySize);
    maxOutProcXElements = max(maxOutProcXElements,pxPos);
    maxOutProcYElements = max(maxOutProcYElements,pyPos);
  else
    outputs{i} = zeros(1,10);
  end
end
outputs = [outputs{:}];

% Bias Hints
biases = cell(1,net.numLayers);
for i=1:net.numLayers
  if net.biasConnect(i)
    bsize = net.biases{i}.size;
    biases{i} = [...
      1 ...
      bsize ...
      hints.allWB.bPos(i)-1 ...
      hints.learnWB.bPos(i)-1 ...
      net.biases{i}.learn ...
      ];
  else
    biases{i} = zeros(1,5);
  end
end
biases = [biases{:}];

% Weight Hints
zPos = 0;
maxDelayedElements = 0;
maxIWSizeByS = 0;
maxNumLWByS = 0;
inputWeights = cell(net.numLayers,net.numInputs);
layerWeights = cell(net.numLayers,net.numLayers);
for i=1:net.numLayers
  inLayerZPos = 0;
  inLayerIWPos = 0;
  inLayerLWIndex = 0;
  
  % Input Weight Hints
  for j=1:net.numInputs
    if net.inputConnect(i,j)
      wsize = numel(net.IW{i,j});
      weightFcn = nnstring.match(net.inputWeights{i,j}.weightFcn,weightFcns);
      delays = net.inputWeights{i,j}.delays;
      numDelays = numel(delays);
      noDelay = (numDelays==1) && (delays==0);
      singleDelay = (numDelays == 1);
      
      inputWeights{i,j} = [...
        1 ...
        wsize ...
        hints.allWB.iwPos(i,j)-1 ...
        hints.learnWB.iwPos(i,j)-1 ...
        inLayerIWPos ...
        0 ... % Not used by input weights
        inLayerZPos ...
        zPos ...
        weightFcn ...
        numDelays ...
        noDelay ...
        singleDelay ...
        numel(intHints) ...
        net.inputWeights{i,j}.learn ...
        ];
      
      maxDelayedElements = max(maxDelayedElements,numel(net.inputWeights{i,j}.delays)*net.inputs{j}.processedSize);
      inLayerZPos = inLayerZPos + net.layers{i}.size;
      inLayerIWPos = inLayerIWPos + wsize;
      zPos = zPos + net.layers{i}.size;
      
      intHints = [intHints; delays(:)];
    else
      inputWeights{i,j} = zeros(1,14);
    end
  end
  maxIWSizeByS = max(maxIWSizeByS,inLayerIWPos * net.layers{i}.size);

  % Layer Weight Hints
  for j=1:net.numLayers
    if net.layerConnect(i,j)
      wsize = numel(net.LW{i,j});
      weightFcn = nnstring.match(net.layerWeights{i,j}.weightFcn,weightFcns);
      delays = net.layerWeights{i,j}.delays;
      numDelays = numel(delays);
      noDelay = (numDelays==1) && (delays==0);
      singleDelay = (numDelays == 1);
      
      layerWeights{i,j} = [...
        1 ...
        wsize ...
        hints.allWB.lwPos(i,j)-1 ...
        hints.learnWB.lwPos(i,j)-1 ...
        0 ... % Unused for layer weights
        inLayerLWIndex ...
        inLayerZPos ...
        zPos ...
        weightFcn ...
        numDelays ...
        noDelay ...
        singleDelay ...
        numel(intHints) ...
        net.layerWeights{i,j}.learn ...
        ];
      
      maxDelayedElements = max(maxDelayedElements,numel(net.layerWeights{i,j}.delays)*net.layers{j}.size);
      inLayerZPos = inLayerZPos + net.layers{i}.size;
      zPos = zPos + net.layers{i}.size;
      inLayerLWIndex = inLayerLWIndex + 1;
      
      % Int Hints
      intHints = [intHints; delays(:)];
    else
      layerWeights{i,j} = zeros(1,14);
    end
  end
  maxNumLWByS = max(maxNumLWByS,sum(net.layerConnect(i,:)) * net.layers{i}.size);

end
inputWeights = inputWeights(:)';
inputWeights = [inputWeights{:}];
layerWeights = layerWeights(:)';
layerWeights = [layerWeights{:}];

% Network Hints
numOutputElements = 0;
inputProcInfoSize = numel(processingInfoArray);
inputProcParamDoubleSize = numel(floatHints);
for i=1:net.numLayers
  if (net.outputConnect(i))
    numOutputElements = numOutputElements + net.outputs{i}.size;
  end
end
numLayerElements = 0;
for i=1:net.numLayers
  numLayerElements = numLayerElements + net.layers{i}.size;
end
numInputElements = 0;
numProcessedInputElements = 0;
for i=1:net.numInputs
  numInputElements = numInputElements + net.inputs{i}.size;
  numProcessedInputElements = numProcessedInputElements + net.inputs{i}.processedSize;
end
perfFcn = nnstring.match(net.performFcn,perfFcns)-1;
perfNorm = feval([net.performFcn '.normalize']);
forwardLayerDelays = nn.forward_layer_delays(net);

totalLayerSize = sum(nn.layer_sizes(net));
maxSignalSize = max([nn.layer_sizes(net); nn.output_sizes(net)]); % TODO - check processed outputs
totalZSize = zPos;

netHints = [...
  hints.allWB.wbLen ...
  hints.learnWB.wbLen ...
  net.numInputs ...
  net.numLayers ...
  net.numOutputs ...
  numInputElements ...
  numProcessedInputElements ...
  numLayerElements ...
  maxLayerSize ...
  totalLayerSize ...
  maxLayerZSize ...
  totalZSize ...
  maxSignalSize ...
  numOutputElements ...
  maxDelayedElements ...
  maxIWSizeByS ...
  maxNumLWByS ...
  net.numInputDelays ...
  net.numLayerDelays ...
  numSimLayers ...
  seriesInputProcElements ...
  maxOutProcXElements ...
  maxOutProcYElements ...
  maxOutputSize ...
  inputProcInfoSize ...
  inputProcParamDoubleSize ...
  perfFcn ...
  perfNorm ...
  forwardLayerDelays ...
  numel(intHints) ...
  ];

% Combine Hints
hints.long = int64([...
  netHints ...
  layerOrder-1 ...
  inputs ...
  layers ...
  outputs ...
  biases ...
  inputWeights ...
  layerWeights ...
  processingInfoArray ...
  intHints' ...
  ]);
hints.double = [ ...
  floatHints ...
  ];

hints.numInputs = net.numInputs;
hints.numLayers = net.numLayers;
hints.numWeightElements = net.numWeightElements;
hints.input_sizes = nn.input_sizes(net);
hints.layer_sizes = nn.layer_sizes(net);
hints.output_sizes = nn.output_sizes(net);
hints.maxSignalSize = maxSignalSize;
hints.numInputDelays = net.numInputDelays;
hints.numLayerDelays = net.numLayerDelays;
hints.perfNorm = perfNorm;
