function hints = netHints(net,hints)

% Copyright 2012 The MathWorks, Inc.

% Function Order
preprocessFcns = {'fixunknowns','mapminmax','mapstd','processpca', ...
  'removeconstantrows','removerows'};

weightFcns = {'convwf','dotprod','negdist','normprod','scalprod',...
  'boxdist','dist','linkdist','mandist'};

netInputFcns = {'netsum','netprod'};

transferFcns = {'compet','hardlim','hardlims','logsig','netinv', ...
  'poslin', 'purelin', 'radbas', 'radbasn', 'satlin', 'satlins', ...
  'softmax', 'tansig', 'tribas','elliotsig','elliot2sig'};

perfFcns = {'','mae','mse','sae','sse'};

layerOrder  = nn.layer_order(net);
numSimLayers = numel(layerOrder);
layer2Output = cumsum(net.outputConnect);

allWB = nnGPU.wb_indices(net,hints,true);
learnWB = nnGPU.wb_indices(net,struct,false);

inputProcInfo = [];
inputProcInfoPos = 0;

intHints = [];
intHintPos = 0;
doubleHints = [];
doubleHintsPos = 0;

% Input Hints
xPos = 0;
pPos = 0;
pOffset = 0;
inputs = cell(1,net.numInputs);
for i=1:net.numInputs
  xSize = net.inputs{i}.size;
  pSize = net.inputs{i}.processedSize;
  infoOffset = inputProcInfoPos;
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
    procFcn = nnstring.match(processFcns{j},preprocessFcns);
    settings = processSettings{j};
    procXSize = settings.xrows;
    procYSize = settings.yrows;
    
    procInfo = [...
      procFcn ... % Processing function index
      pPos ... % Position in processed 
      0 ... % Unused field for inputs, used by outputs
      procXSize ... % X-size (pre-processed input)
      procYSize ... % Y-size (post-processed input)
      doubleHintsPos ... % Offset of double processing parameters
      ];
    
    switch processFcns{j}
      case 'mapminmax',
        doubleParam = [settings.xoffset; settings.gain; settings.ymin];
      otherwise, error('Unsupported processing function.');
    end
    
    inputProcInfo = [inputProcInfo procInfo];
    inputProcInfoPos = inputProcInfoPos + numel(procInfo);
    
    doubleHints = [doubleHints doubleParam(:)'];
    doubleHintsPos = doubleHintsPos + numel(doubleParam);
    
    pPos = pPos + settings.yrows;
  end
  
  inputs{i} = [...
    xSize ...
    xPos ...
    pSize ...
    pOffset ...
    numProc ...
    infoOffset ...
    ];
  xPos = xPos + xSize;
  pOffset = pOffset + pSize;
  
end
inputs = [inputs{:}];
seriesInputProcElements = pPos;

% Layer Hints
aPos = 0;
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
  maxLayerSize = max(maxLayerSize,aSize);
end
layers = [layers{:}];

% Output Hints
yPos = 0;
outputs = cell(1,net.numOutputs);
maxOutProcXElements = 0;
maxOutProcYElements = 0;
maxOutputSize = 0;
for i=1:net.numLayers
  apPos = 0;
  dyPos = 0;
  if net.outputConnect(i)
    ySize = net.outputs{i}.processedSize;
    infoOffset = inputProcInfoPos;
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
      procFcn = nnstring.match(processFcns{j},preprocessFcns);
      settings = processSettings{j};
      procXSize = settings.xrows;
      procYSize = settings.yrows;
      
      procInfo = [...
        procFcn ... % Processing function index
        dyPos ... % Position in Processed Output Derivatives
        apPos ... % Position in Processed Outputs
        procXSize ... % X-size (pre-processed target, post-processed output)
        procYSize ... % Y-size (post-processed target, pre-processed output)
        doubleHintsPos ... % Offset of double processing parameters
        ];

      switch processFcns{j}
        case 'mapminmax',
          doubleParam = [settings.xoffset; settings.gain; settings.ymin];
        otherwise, error('Unsupported processing function.');
      end

      inputProcInfo = [inputProcInfo procInfo];
      inputProcInfoPos = inputProcInfoPos + numel(procInfo);

      doubleHints = [doubleHints doubleParam(:)'];
      doubleHintsPos = doubleHintsPos + numel(doubleParam);

      apPos = apPos + settings.xrows;
      dyPos = dyPos + settings.yrows;
    end
    
    
    % Double Hints
    errNormOffset = doubleHintsPos;
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
    doubleHints = [doubleHints errNorm'];
    doubleHintsPos = doubleHintsPos + length(errNorm);
    
    % Combine Output Hints
    outputs{i} = [...
      1 ... % Output is connected
      sum(net.outputConnect(1:i))-1 ... % Output index
      ySize ... % Number of elements in this output
      yPos ... % Pos in complete netork output = Number of elements in prior outputs
      numProc ... % Number of output processing functions
      infoOffset ... % Position of output processing structures
      doErrNorm ... % Flag indicating whether to normalize error for output range
      errNormOffset ... % Position for error normalization  vector
      ];
    
    yPos = yPos + ySize;
    maxOutputSize = max(maxOutputSize,ySize);
    maxOutProcXElements = max(maxOutProcXElements,apPos);
    maxOutProcYElements = max(maxOutProcYElements,dyPos);
  else
    outputs{i} = zeros(1,8);
  end
end
outputs = [outputs{:}];

% Bias Hints
biases = cell(1,net.numLayers);
for i=1:net.numLayers
  if net.biasConnect(i)
    bsize = net.biases{i}.size;
    allBPos = allWB.bPos(i)-1;
    learnBPos = learnWB.bPos(i)-1;
    biases{i} = [...
      1 ...
      bsize ...
      allBPos ...
      learnBPos ...
      net.biases{i}.learn ...
      ];
  else
    biases{i} = [0 0 0 0 0];
  end
end
biases = [biases{:}];

% Input Weight Hints
maxDelayedElements = 0;
inputWeights = cell(net.numLayers,net.numInputs);
for i=1:net.numLayers
  for j=1:net.numInputs
    if net.inputConnect(i,j)
      wsize = numel(net.IW{i,j});
      allWPos = allWB.iwPos(i,j)-1;
      learnWPos = learnWB.iwPos(i,j)-1;
      weightFcn = nnstring.match(net.inputWeights{i,j}.weightFcn,weightFcns);
      delays = net.inputWeights{i,j}.delays;
      numDelays = numel(delays);
      noDelay = (numDelays==1) && (delays==0);
      singleDelay = (numDelays == 1);
      inputWeights{i,j} = [...
        1 ... % Connected
        wsize ... % Weight Size
        allWPos ... % Weight offset in WB vector
        learnWPos ... % Weight offset in dWB vector
        weightFcn ... % Weight function index
        numDelays ...  % Number of delay states
        max([0 delays]) ... % Maximum delay state
        noDelay ...
        singleDelay ...
        intHintPos ... % Offset in integer hints of delays
        net.inputWeights{i,j}.learn ...
        ];
      maxDelayedElements = max(maxDelayedElements,numel(net.inputWeights{i,j}.delays)*net.inputs{j}.processedSize);
      
      % Double Hints
      intHints = [intHints delays];
      intHintPos = intHintPos + length(delays);
    else
      inputWeights{i,j} = [0 0 0 0 0 0 0 0 0 0 0];
    end
  end
end
inputWeights = inputWeights(:)';
inputWeights = [inputWeights{:}];

% Layer Weight Hints
layerWeights = cell(net.numLayers,net.numLayers);
for i=1:net.numLayers
  for j=1:net.numLayers
    if net.layerConnect(i,j)
      wsize = numel(net.LW{i,j});
      allWPos = allWB.lwPos(i,j)-1;
      learnWPos = learnWB.lwPos(i,j)-1;
      weightFcn = nnstring.match(net.layerWeights{i,j}.weightFcn,weightFcns);
      delays = net.layerWeights{i,j}.delays;
      numDelays = numel(delays);
      noDelay = (numDelays==1) && (delays==0);
      singleDelay = (numDelays == 1);
      layerWeights{i,j} = [...
        1 ... % Connected
        wsize ... % Weight Size
        allWPos ...  ... % Weight offset in WB vector
        learnWPos ... % Weight offset in dWB vector
        weightFcn ... % Weight function index
        numDelays ... % Number of delay states
        max([0 delays]) ...  % Maximum delay state
        noDelay ...
        singleDelay ...
        intHintPos ... . % Offset in integer hints of delays
        net.layerWeights{i,j}.learn ...
        ];
      maxDelayedElements = max(maxDelayedElements,numel(net.layerWeights{i,j}.delays)*net.layers{j}.size);
      
      % Int Hints
      intHints = [intHints delays];
      intHintPos = intHintPos + length(delays);
    else
      layerWeights{i,j} = [0 0 0 0 0 0 0 0 0 0 0];
    end
  end
end
layerWeights = layerWeights(:)';
layerWeights = [layerWeights{:}];

% Network Hints
numOutputElements = 0;
inputProcInfoSize = numel(inputProcInfo);
inputProcParamDoubleSize = numel(doubleHints);
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

numAlignedWeightElements = allWB.wbLen;

netHints = [...
  net.numWeightElements ...
  numAlignedWeightElements ...
  net.numInputs ...
  net.numLayers ...
  net.numOutputs ...
  numInputElements ...
  numProcessedInputElements ...
  numLayerElements ...
  maxLayerSize ...
  totalLayerSize ...
  maxSignalSize ...
  numOutputElements ...
  maxDelayedElements ...
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
  perfNorm ... % 21
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
  inputProcInfo ...
  intHints ...
  0 ... % This value avoids GPU problem of possible empty array
  ]);
hints.double = feval(hints.precision,[ ...
  doubleHints ...
  0 ... % This value avoids GPU problem of possible empty array
  ]);

hints.numLayers = net.numLayers;
hints.numWeightElements = net.numWeightElements;
hints.input_sizes = nn.input_sizes(net);
hints.layer_sizes = nn.layer_sizes(net);
hints.output_sizes = nn.output_sizes(net);
hints.maxSignalSize = maxSignalSize;
hints.numInputDelays = net.numInputDelays;
hints.numLayerDelays = net.numLayerDelays;
hints.perfNorm = perfNorm;

hints.matlabAllWB = nn.wb_indices(net,struct,true);
hints.matlabLearnWB = nn.wb_indices(net,struct,false);
hints.gpuAllWB = allWB;
hints.gpuLearnWB = learnWB;
hints.startGPUWB = getwb(net,hints.gpuAllWB);

