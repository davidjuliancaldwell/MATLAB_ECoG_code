function [calcMode,calcNet,calcData,calcHints,net,resourceText] = setup1(calcMode,net,data)
% First step of setup for calculation mode, net, data & hints for
% parallel or non-parallel calculations.  Must be called outside of SPMD.

% Copyright 2012 The MathWorks, Inc.

if isfield(calcMode,'showResources')
  showResources = calcMode.showResources;
else
  showResources = false;
end

%% CHANGE TOP PARALLEL/GPU CALC MODE IF REQUIRED BY DATA
% ======================================================

% If Composite data => Add top mode nnParallel
isComposite = isa(data,'Composite');
if isComposite && ~strcmp(calcMode.mode,'nnParallel')
  calcMode = nnParallel('subcalc',calcMode);
end

% If gpuArray data => Change top mode is nnGPU
isGPUArray = ~isComposite && isa(data.X,'parallel.gpu.GPUArray');
if isGPUArray && ~strcmp(calcMode.mode,'nnGPU')
  precision = class(gather(data.X(1)));
  calcMode = nnGPU('precision',precision);
end

% Fill out default subcalcs
net = struct(net);
calcMode = nncalc.defaultMode(net,calcMode);

%% REMOVE PARALLEL/GPU TOP CALC MODE IF LIMITED BY RESOURCES
% ==========================================================

% If no MATLAB pool => Remove nnParallel
poolSize = nnParallel.poolSize;
if isComposite && (poolSize == 0)
  poolSize = 1;
elseif strcmp(calcMode.mode,'nnParallel') && (poolSize == 0)
  calcMode = calcMode.hints.subcalc;
end

% If not suitable GPU => Remove nnGPU
if strcmp(calcMode.mode,'nnGPU') && (~nnGPU.isSupported)
  calcMode = calcMode.hints.subcalc;
end

% Basic Calculation Hints
calcHints = calcMode.hints;
calcHints.isComposite = isComposite;  % TRAIN/SIM arguments are gpuArray
calcHints.isGPUArray = isGPUArray; % TRAIN/SIM arguments are gpuArray
calcHints.numOutputs = net.numOutputs;
calcHints.outputSizes = nn.output_sizes(net);
if isempty(net.performFcn)
  calcHints.perfNorm = false;
  calcHints.regularization = 0;
else
  calcHints.perfWB = str2func([net.performFcn '.perfwb']);
  calcHints.dPerfWB = str2func([net.performFcn '.dperf_dwb']);
  calcHints.perfParam = net.performParam;
  calcHints.perfNorm = feval([net.performFcn,'.normalize']);
  if isfield(net.performParam,'regularization')
    calcHints.regularization = net.performParam.regularization;
  else
    calcHints.regularization = 0;
  end
end
calcHints.learnWB = nn.wb_indices(net,struct,false);
doPc = true; % TODO - Make optional


%% MATLAB Calc Mode for pre-Calc
% ==============================
matlabMode = nnMATLAB;
matlabHints = matlabMode.hints;
matlabHints = nnMATLAB.netHints(net,matlabHints);

%% NOT PARALLEL
% =============
if ~strcmp(calcMode.mode,'nnParallel')
  
  % Main Worker
  calcMode.isActiveWorker = true;
  calcMode.isMainWorker = true;
  calcMode.mainWorkerInd = 1;
  calcMode.isParallel = false;
  calcHints.isActiveWorker = true;
  
  % Qu, TSu (Q and TS unflattened)
  calcHints.Qu = data.Q;
  calcHints.TSu = data.TS;
  
  % Pre-calculate Pc, Pd and flattened time, as appropriate
  PdOk = checkPdImplemented(calcMode);
  doPd = (net.numInputDelays > 0) && net.efficiency.cacheDelayedInputs && PdOk;
  calcHints.doFlattenTime = net.efficiency.flattenTime && (net.numLayerDelays==0) && ...
    (calcHints.TSu > 1) && ((net.numInputDelays==0) || doPd);
  calcData = nncalc.preCalcData(matlabMode,matlabHints,net,data,doPc,doPd,calcHints.doFlattenTime);
  
  % Update Network
  if ~isdeployed && ~isempty(net.trainFcn)
    trainInfo = feval(net.trainFcn,'info');
    if strcmp(calcMode.mode,'nnGPU') && trainInfo.usesJacobian
      net.trainFcn = 'trainscg';
      net.trainParam = struct(trainscg('defaultParam'));
      disp('NOTICE: Jacobian training not supported on GPU. Training function set to TRAINSCG.');
    end
  end
  
  calcNet = net;
  calcHints = calcMode.netHints(net,calcHints);
  
  if showResources
    resourceText = mode2Text(calcMode,calcHints);
  else
    resourceText = {};
  end
  return
end

%% PARALLEL INFO: workerInd,workerModes, workerQs, workerTS, usesGPU
% ==================================================================

subMode = calcMode.hints.subcalc;
calcMode.isParallel = true;

% Case 1: Composite Data
if isComposite
  subModeIsGPU = strcmp(subMode.mode,'nnGPU');
  subPrecision = subMode.hints.precision;

  % gather worker info
  spmd
    workerInfo = struct;
    if isempty(data) || (data.Q == 0)
      workerInfo.Q = 0;
      workerInfo.TS = 0;
      workerInfo.precision = '';
      workerInfo.isGPUArray = false;
      workerInfo.gpuID = '';
    elseif isa(data.X,'parallel.gpu.GPUArray')
      workerInfo.Q = data.Q;
      workerInfo.TS = data.TS;
      workerInfo.precision = class(gather(data.X(1)));
      workerInfo.isGPUArray = true;
      workerInfo.gpuID = nnParallel.gpuID;
    elseif subModeIsGPU
      workerInfo.Q = data.Q;
      workerInfo.TS = data.TS;
      workerInfo.precision = subPrecision;
      workerInfo.isGPUArray = false;
      workerInfo.gpuID = nnParallel.gpuID;
    else
      workerInfo.Q = data.Q;
      workerInfo.TS = data.TS;
      workerInfo.precision = subPrecision;
      workerInfo.isGPUArray = false;
      workerInfo.gpuID = '';
    end
  end
  workerInfo = nnParallel.composite2Cell(workerInfo);
  workerInfo = [ workerInfo{:} ];
  workerQs = [ workerInfo(:).Q ];
  activeWorkers = (workerQs > 0);
  workerInd = find(activeWorkers);
  
  if isempty(workerInd)
    workerInd = 1;
  end
  
  workerTSs = [workerInfo(:).TS];
  activeTS = workerTSs(activeWorkers);
  workerTS = max([0 activeTS]);
  if any(activeTS ~= workerTS)
    error('Cannot compute with inconsistent timesteps across workers.');
  end
  workerPrecisions = { workerInfo(:).precision };
  if numel(unique([workerPrecisions {''}])) > 2
    error('Cannot compute with inconsistent precision across workers.');
  end
  workerGPUIDs = { workerInfo(:).gpuID };
  % Any GPUs?
  usesGPU = (numel(unique([{''} workerGPUIDs])) > 1);
  % Assign sub modes
  workerModes = cell(1,poolSize);
  for i=workerInd
    if ~isempty(workerGPUIDs{i})
      % GPU Submode
      workerModes{i} = nnGPU('precision',workerPrecisions{i});
    elseif subModeIsGPU
      % GPU Fallback
      workerModes{i} = subMode.hints.subcalc;
    else
      % Regular Submode
      workerModes{i} = subMode;
    end
  end

  calcHints.Qu = sum(workerQs);
  calcHints.TSu = workerTS;
  
% Case 2: MATLAB Data, subcalc GPU, onlyGPUs
elseif strcmp(subMode.mode,'nnGPU') && calcMode.hints.onlyGPUs

  % gather worker info
  spmd
    gpuIDs = nnParallel.gpuID;
  end
  gpuIDs = nnParallel.composite2Cell(gpuIDs);

  [~,workerInd] = unique([{''} gpuIDs],'first');
  workerInd = workerInd(2:end)-1;
  
  % If no GPU workers fallback
  usesGPU = ~isempty(workerInd);
  if ~usesGPU
    workerInd = 1:poolSize;
    subMode = nncalc.defaultMode(net);
  end
    
  workerModes = cell(1,poolSize);
  for i=workerInd
    workerModes{i} = subMode;
  end
  
  % Pre-process, pre-delay and flatten in aggregate
  calcHints.Qu = data.Q;
  calcHints.TSu = data.TS;
  PdOk = checkPdImplemented(calcMode);
  doPd = (net.numInputDelays > 0) && net.efficiency.cacheDelayedInputs && PdOk;
  calcHints.doFlattenTime = net.efficiency.flattenTime && (net.numLayerDelays==0) && ...
    (calcHints.TSu > 1) && ((net.numInputDelays==0) || doPd);
  data = nncalc.preCalcData(matlabMode,matlabHints,net,data,doPc,doPd,calcHints.doFlattenTime);
  calcHints.Q = data.Q;
  calcHints.TS = data.TS;

  % Load Balance
  workerQs = zeros(1,poolSize);
  workerQs(workerInd) = nnParallel.loadBalance(data.Q,numel(workerInd));
  
% Case 3: MATLAB Data, subcalc GPU, ~GPUonly
elseif strcmp(subMode.mode,'nnGPU') && ~calcMode.hints.onlyGPUs

  % gather worker info
  spmd
    gpuIDs = nnParallel.gpuID;
  end
  gpuIDs = nnParallel.composite2Cell(gpuIDs);

  [~,gpuInd] = unique([{''} gpuIDs],'first');
  gpuInd = gpuInd(2:end)-1;
  usesGPU = ~isempty(gpuInd);
  workerInd = 1:poolSize;
  workerModes = cell(1,poolSize);
  fallbackMode = subMode.hints.subcalc;
  for i=workerInd
    if ~isempty(find(i==gpuInd,1))
      workerModes{i} = subMode;
    else
      workerModes{i} = fallbackMode;
    end
  end

  % Pre-process, pre-delay and flatten in aggregate
  calcHints.Qu = data.Q;
  calcHints.TSu = data.TS;
  PdOk = checkPdImplemented(calcMode);
  doPd = (net.numInputDelays > 0) && net.efficiency.cacheDelayedInputs && PdOk;
  calcHints.doFlattenTime = net.efficiency.flattenTime && (net.numLayerDelays==0) && ...
    (calcHints.TSu > 1) && ((net.numInputDelays==0) || doPd);
  data = nncalc.preCalcData(matlabMode,matlabHints,net,data,doPc,doPd,calcHints.doFlattenTime);
  calcHints.Q = data.Q;
  calcHints.TS = data.TS;

  % Load Balance
  workerQs = zeros(1,poolSize);
  workerQs(workerInd) = nnParallel.loadBalance(data.Q,numel(workerInd));

% Case 4: MATLAB Data, subcalc non-GPU
else
  workerModes = repmat({subMode},1,poolSize);
  
  % Pre-process, pre-delay and flatten in aggregate
  calcHints.Qu = data.Q;
  calcHints.TSu = data.TS;
  PdOk = checkPdImplemented(calcMode);
  doPd = (net.numInputDelays > 0) && net.efficiency.cacheDelayedInputs && PdOk;
  calcHints.doFlattenTime = net.efficiency.flattenTime && (net.numLayerDelays==0) && ...
    (calcHints.TSu > 1) && ((net.numInputDelays==0) || doPd);
  data = nncalc.preCalcData(matlabMode,matlabHints,net,data,doPc,doPd,calcHints.doFlattenTime);
  calcHints.Q = data.Q;
  calcHints.TS = data.TS;

  % Load Balance
  workerQs = nnParallel.loadBalance(data.Q,poolSize);
  usesGPU = false;
end

% Update Network
if ~isdeployed && ~isempty(net.trainFcn)
  trainInfo = feval(net.trainFcn,'info');
  if usesGPU && trainInfo.usesJacobian
    net.trainFcn = 'trainscg';
    net.trainParam = struct(trainscg('defaultParam'));
    disp('NOTICE: Jacobian training not supported on GPU. Training function set to TRAINSCG.');
  end
end

%% Setup Workers
% ==============

workerInd = find(workerQs > 0);
if isempty(workerInd)
  workerInd = 1;
end
calcHints.workerQs = workerQs;
calcHints.numSlices = numel(workerInd);
calcHints.allSliceIndices = cell(1,poolSize);
workerStops = cumsum(workerQs);
workerStarts = [1 workerStops(1:(end-1))+1];
for i=workerInd
  calcHints.allSliceIndices{i} = workerStarts(i):workerStops(i);
end

calcMode.workerInd = workerInd;
calcHints.workerInd = workerInd;
calcMode.mainWorkerInd = workerInd(1);
calcHints.mainWorkerInd = workerInd(1);

% Set up Composite calcMode, pre-calculated calcData, calcNet and calcHints
if ~isComposite
    
  % Distribute data
  calcData = Composite;
  for i=workerInd
    
    % Split Data
    qq = calcHints.allSliceIndices{i};
    datai = nncalc.split_data(data,qq);
    
    % Do not pre-calc data individually
    %calcHints.Q = data.Q;
    %calcHints.TS = data.TS;
    %calcHints.Qu = data.Q;
    %calcHints.TSu = data.TS;
    datai.doFlattenTime = false;
    
    calcData{i} = datai;
    calcHints = calcMode.netHints(net,calcHints);
  end
  workerModes = nnParallel.cell2Composite(workerModes);
  calcMode = nnParallel.copy2Composite(calcMode);
  calcNet = nnParallel.copy2Composite(net);
  calcHints = nnParallel.copy2Composite(calcHints);
  spmd
    calcMode.isMainWorker = (calcMode.mainWorkerInd == labindex);
    if ~isempty(workerModes) && any(workerInd == labindex)
      calcMode.isActiveWorker = true;
      calcHints.isActiveWorker = true;
      calcHints.subcalc = workerModes;
      calcHints.subhints = workerModes.hints;
      calcHints.subhints = calcHints.subcalc.netHints(calcNet,calcHints.subhints);
      calcHints.subhints.isGPUArray = isa(calcData.X,'parallel.gpu.GPUArray');
    else
      calcMode.isActiveWorker = false;
      calcNet = [];
      calcData = [];
      calcHints = struct;
      calcHints.isActiveWorker = false;
      calcHints.isMainWorker = false;
      calcHints.mainWorkerInd = calcMode.mainWorkerInd;
    end
    if showResources
      if calcHints.isActiveWorker
        workerResourceTexts = mode2Text(calcHints.subcalc,calcHints.subhints);
      else
        workerResourceTexts = {'Unused'};
      end
      hostIDs = nnParallel.hostID;
    end
  end
else
  
  % Do not pre-calc data in aggregate
  calcHints.doFlattenTime = false;
  calcHints.Q = calcHints.Qu;
  calcHints.TS = calcHints.TSu;
  
  % Pre-process, pre-delay and flatten individually
  calcData = data;
  workerModes = nnParallel.cell2Composite(workerModes);
  calcMode = nnParallel.copy2Composite(calcMode);
  calcNet = nnParallel.copy2Composite(net);
  calcHints = nnParallel.copy2Composite(calcHints);
  spmd
    calcMode.isMainWorker = (calcMode.mainWorkerInd == labindex);
    if ~isempty(workerModes)
      calcMode.isActiveWorker = true;
      calcHints.isActiveWorker = true;
      calcHints.isMainWorker = (calcMode.mainWorkerInd == labindex);
      calcHints.subcalc = workerModes;
      calcHints.subhints = workerModes.hints;
      calcHints.subhints = calcHints.subcalc.netHints(calcNet,calcHints.subhints);

      calcHints.subhints.Qu = data.Q;
      calcHints.subhints.TSu = data.TS;
      PdOk = checkPdImplemented(calcMode);
      doPd = (net.numInputDelays > 0) && net.efficiency.cacheDelayedInputs && PdOk;
      calcHints.subhints.flattenTime = net.efficiency.flattenTime && (net.numLayerDelays==0) && ...
        (calcHints.TSu > 1) && ((net.numInputDelays==0) || doPd);
      calcData = nncalc.preCalcData(matlabMode,matlabHints,net,calcData,doPc,doPd,calcHints.subhints.flattenTime);
      calcHints.subhints.Q = data.Q;
      calcHints.subhints.TS = data.TS;
      calcHints.subhints.isGPUArray = isa(calcData.X,'parallel.gpu.GPUArray');
    else
      calcMode.isActiveWorker = false;
      calcNet = [];
      calcData = [];
      calcHints = struct;
      calcHints.isActiveWorker = false;
      calcHints.isMainWorker = false;
      calcHints.mainWorkerInd = calcMode.mainWorkerInd;
    end
    if showResources
      if calcHints.isActiveWorker
        workerResourceTexts = mode2Text(calcHints.subcalc,calcHints.subhints);
      else
        workerResourceTexts = {'Unused'};
      end
      hostIDs = nnParallel.hostID;
    end
  end
end
if showResources
  workerTexts = nnParallel.composite2Cell(workerResourceTexts);
  hostIDs = nnParallel.composite2Cell(hostIDs);
  for i=1:numel(workerTexts)
    texti = workerTexts{i};
    texti{1} = ['Worker ' num2str(i) ' on ' hostIDs{i} ', ' texti{1}];
    workerTexts{i} = texti;
  end
  line1 = 'Parallel Workers:';
  workerText = indentText([workerTexts{:}]');
  resourceText = [{line1}; workerText];
else
  resourceText = {};
end

function flag = checkPdImplemented(calcMode)

if strcmp(calcMode.mode,'nnMex')
  flag = false;
elseif strcmp(calcMode.mode,'nnGPU')
  flag = false;
elseif isfield(calcMode.hints,'subcalc')
  flag = checkPdImplemented(calcMode.hints.subcalc);
elseif isfield(calcMode.hints,'subcalcs')'
  for i=1:numel(calcMode.hints.subcalcs)
    if ~checkPdImplemented(calcMode.hints.subcalcs{i})
      flag = false;
      return
    end
  end
  flag = true;
else
  flag = true;
end

function modeText = mode2Text(calcMode,calcHints)  
  
switch calcMode.mode

  case 'nn2Point'
    subText = mode2Text(calcHints.subcalc);
    line1 = ['2-Point Approximation, ' subText{1}];
    modeText = [{line1} indentText(subText(2:end))];

  case 'nn5Point'
    subText = mode2Text(calcHints.subcalc);
    line1 = ['5-Point Approximation, ' subText{1}];
    modeText = [{line1} indentText(subText(2:end))];

  case 'nn7'
    modeText = {['MATLAB on ' computer]};

  case 'nnCompare'
    numModes = numel(calcHints.subcalcs);
    subText = {};
    for i=1:numModes
      subText = [subText; mode2Text(calcHints.subcalcs{i})];
    end
    line1 = ['Comparing ' num2str(numModes) ' Alternatives:'];
    modeText = [{line1}; indentText(subText)];

  case 'nnGPU'
    gpuInfo = gpuDevice;
    modeText = {['GPU device ' num2str(gpuInfo.Index) ', ' gpuInfo.Name]};

  case 'nnMATLAB'
    modeText = {['MATLAB on ' computer]};

  case 'nnMemReduc'
    subText = mode2Text(calcHints.subcalc);
    line1 = ['Memory Reduction ' num2str(calcHints.reduction) ', ' subText{1}];
    modeText = [{line1} indentText(subText(2:end))];

  case 'nnMex'
    modeText = {['MEX on ' computer]};

  case 'nnNPoint'
    subText = mode2Text(calcHints.subcalc);
    line1 = ['N-Point Approximation, ' subText{1}];
    modeText = [{line1} indentText(subText(2:end))];

  case 'nnSimple'
    modeText = {['MATLAB on ' computer]};
    
  otherwise
    modeText = {calcMode.name};
end

function text = indentText(text)

for i=1:numel(text)
  text{i} = ['  ' text{i}];
end
