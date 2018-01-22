function [net,tr,out3,out4,out5,out6]=train(net,varargin)
%TRAIN Train a neural network.
%
%  [NET,TR] = <a href="matlab:doc train">train</a>(NET,X,T) takes a network NET, input data X
%  and target data T and returns the network after training it, and a
%  a training record TR.
%
%  [NET,TR] = <a href="matlab:doc train">train</a>(NET,X) takes only input data, in cases where
%  the network's training function is unsupervised (i.e. does not require
%  target data).
%
%  [NET,TR] = <a href="matlab:doc train">train</a>(NET,X,T,Xi,Ai,EW) takes additional optional
%  arguments suitable for training dynamic networks and training with
%  error weights.  Xi and Ai are the initial input and layer delays states
%  respectively and EW defines error weights used to indicate
%  the relative importance of each target value.
%
%  <a href="matlab:doc train">train</a> calls the network training function NET.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> with the
%  parameters NET.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a> to perform training.  Training functions
%  may also be called directly.
%
%  <a href="matlab:doc train">train</a> arguments can have two formats: matrices, for static
%  problems and networks with single inputs and outputs, and cell arrays
%  for multiple timesteps and networks with multiple inputs and outputs.
%
%  The matrix format is as follows:
%    X  - RxQ matrix
%    Y  - UxQ matrix.
%  Where:
%    Q  = number of samples
%    R  = number of elements in the network's input
%    U  = number of elements in the network's output
%
%  The cell array format is most general:
%    X  - NixTS cell array, each element X{i,ts} is an RixQ matrix.
%    Xi - NixID cell array, each element Xi{i,k} is an RixQ matrix.
%    Ai - NlxLD cell array, each element Ai{i,k} is an SixQ matrix.
%    Y  - NOxTS cell array, each element Y{i,ts} is a UixQ matrix.
%    Xf - NixID cell array, each element Xf{i,k} is an RixQ matrix.
%    Af - NlxLD cell array, each element Af{i,k} is an SixQ matrix.
%  Where:
%    TS = number of time steps
%    Ni = NET.<a href="matlab:doc nnproperty.net_numInputs">numInputs</a>
%    Nl = NET.<a href="matlab:doc nnproperty.net_numLayers">numLayers</a>, 
%    No = NET.<a href="matlab:doc nnproperty.net_numOutputs">numOutputs</a>
%    ID = NET.<a href="matlab:doc nnproperty.net_numInputDelays">numInputDelays</a>
%    LD = NET.<a href="matlab:doc nnproperty.net_numLayerDelays">numLayerDelays</a>
%    Ri = NET.<a href="matlab:doc nnproperty.net_inputs">inputs</a>{i}.<a href="matlab:doc nnproperty.input_size">size</a>
%    Si = NET.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_size">size</a>
%    Ui = NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_size">size</a>
%
%  The error weights EW can be 1, indicating all targets are equally
%  important.  It can also be either a 1xQ vector defining relative sample
%  importances, a 1xTS cell array of scalar values defining relative
%  timestep importances, an Nox1 cell array of scalar values defining
%  relative network output importances, or in general an NoxTS cell array
%  of NixQ matrices (the same size as T) defining every target element's
%  relative importance.
%
%  Here a static feedforward network is created, trained on some data, then
%  simulated using SIM and network notation.
%
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    y1 = <a href="matlab:doc sim">sim</a>(net,x)
%    y2 = net(x)
%
%  Here a dynamic NARX network is created, trained, and simulated on
%  time series data.
%
%   [X,T] = <a href="matlab:doc simplenarx_dataset">simplenarx_dataset</a>;
%   net = <a href="matlab:doc narxnet">narxnet</a>(1:2,1:2,10);
%   <a href="matlab:doc view">view</a>(net)
%   [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,{},T);
%   net = <a href="matlab:doc train">train</a>(net,Xs,Ts,Xi,Ai);
%   Y = net(Xs,Xi,Ai)
%
%  Training with Parallel Computing:
%
%  Parallel Computing Toolbox allows Neural Network Toolbox to train
%  networks faster and on larger datasets than can fit on one PC.
%
%  Here training automatically happens across MATLAB workers.
%
%    matlabpool open
%    [X,T] = vinyl_dataset;
%    net = feedforwardnet;
%    net = <a href="matlab:doc train">train</a>(net,X,T,'useParallel','yes','showResources','yes');
%    Y = net(X);
%
%  Use Composite values to distribute the data manually, and get back
%  the results as a Composite value.  If the data is loaded as it is
%  distributed then while each peice of the dataset must fit in RAM, the
%  entire dataset is only limited by the number of workers RAM.
%
%    Xc = Composite;
%    Tc = Composite;
%    for i=1:numel(Xc)
%      Xc{i} = X+rand(size(X))*0.1; % (Use real data instead
%      Tc{i} = T+rand(size(T))*0.1; % instead of random data)
%    end
%    net = <a href="matlab:doc train">train</a>(net,Xc,Tc,'showResources','yes');
%    Yc = net(Xc);
%
%  Networks can be trained using the current GPU device, if it is
%  supported by the Parallel Computing Toolbox.
%
%    net = <a href="matlab:doc train">train</a>(net,X,T,'useGPU','yes','showResources','yes');
%    Y = net(X);
%
%  To put the data on a GPU manually:
%
%    Xgpu = <a href="matlab:doc nndata2gpu">nndata2gpu</a>(X);
%    Tgpu = <a href="matlab:doc nndata2gpu">nndata2gpu</a>(T);
%    net = <a href="matlab:doc train">train</a>(net,Xgpu,Tgpu,'showResources','yes');
%    Ygpu = net(Xgpu);
%    Y = <a href="matlab:doc gpu2nndata">gpu2nndata</a>(Ygpu);
%
%  To run in parallel, with workers associated with unique GPUs taking
%  advantage of that hardware, while the rest of the workers use CPUs:
%
%    net = <a href="matlab:doc train">train</a>(net,X,T,'useParallel','yes','useGPU','yes','showResources','yes');
%    Y = net(X);
%
%  Only using workers with unique GPUs may result in higher speed, as CPU
%  workers may not keep up.
%
%    net = <a href="matlab:doc train">train</a>(net,X,T,'useParallel','yes','useGPU','only','showResources','yes');
%    Y = net(X);
%
%  Or manually distribute data as a Composite, choosing the size of each
%  subset of data to match whether each worker has a GPU or not.  For
%  instance, if only the first two workers have unique GPUs:
%
%    Xc = Composite;
%    for i=1:numel(Xc)
%      Xc{i} = X+rand(size(X))*0.1; % (Use real data instead
%      Tc{i} = T+rand(size(T))*0.1; % instead of random data)
%    end
%    spmd
%      if labindex <=2
%        Xc = <a href="matlab:doc nndata2gpu">nndata2gpu</a>(Xc);
%        Tc = <a href="matlab:doc nndata2gpu">nndata2gpu</a>(Tc);
%      end
%    end
%    net = <a href="matlab:doc train">train</a>(net,Xc,Tc,'showResources','yes');
%    Yc = net(Xc);
%
%  Defining Composite values as above can also let you balance each subset
%  of data for GPUs with differing speeds and memory.
%
%  See also INIT, REVERT, SIM, ADAPT, VIEW.

%  Mark Beale, 11-31-97
%  Copyright 1992-2012 The MathWorks, Inc.
%  $Revision: 1.11.4.19.2.1 $ $Date: 2012/07/28 23:34:28 $

% Network
if ~isa(net,'network')
  error('nnet:train:arguments','First argument is not a neural network.');
end
% Network
net = struct(net);
if ~isfield(net,'version') || ~ischar(net.version) || ~strcmp(net.version,'7')
  net = nnupdate.net(net);
end
[~,zeroDelayLoop] = nn.layer_order(net);
 if zeroDelayLoop, error(message('nnet:NNet:ZeroDelayLoop')); end
if isempty(net.trainFcn), error(message('nnet:NNet:TrainFcnUndefined')); end
info = feval(net.trainFcn,'info');
if info.isSupervised && isempty(net.performFcn)
  error(message('nnet:NNet:SupTrainFcnNoPerformFcn'));
end
net.efficiency.flattenedTime = net.efficiency.flattenTime && (~strcmp(net.trainFcn,'trains'));

% NNET 5.1 Compatibility
if (nargin == 6) && (isstruct(varargin{5}) && hasfield(varargin{5},'P'))
  net = network(net);
  [net,tr,out3,out4,out5,out6] = v51_train_arg6(net,varargin{:});
  return
elseif (nargin == 7) && ((isstruct(varargin{5}) && hasfield(varargin{5},'P')) || (isstruct(varargin{6}) && isfield(varargin{6},'P')))
  net = network(net);
  [net,tr,out3,out4,out5,out6] = v51_train_arg7(net,varargin{:});
  return
end

% Calculation Mode
if ~isempty(varargin) && isstruct(varargin{end}) && isfield(varargin{end},'name')
  calcMode = nncalc.defaultMode(net,varargin{end}); varargin(end) = [];
else
  n = numel(varargin);
  i = n + 1;
  while (i-2 > 0) && ischar(varargin{i-2})
    i = i - 2;
  end
  if (i < n)
    nameValuePairs = varargin(i:n);
    varargin(i:n) = [];
    [calcMode,err] = nncalc.options2Mode(net,nameValuePairs);
    if ~isempty(err), error('nnet:train:calcMode',err); end
  else
    calcMode = nncalc.defaultMode(net);
  end
end
problem = calcMode.netCheck(net,calcMode.hints,false,false);
if ~isempty(problem), error(problem); end

% Check Composite Data for consistency
nargs = numel(varargin);
if nargs >= 1
  isComposite = isa(varargin{1},'Composite');
else
  isComposite = false;
end
for i=2:nargs
  if isComposite ~= isa(varargin{i},'Composite')
    error('nnet:sim:Composite','Data values must be all Composite or not.');
  end
end

% Check gpuArray data for consistency
if nargs >= 1
  isGPUArray = isa(varargin{1},'parallel.gpu.GPUArray');
else
  isGPUArray = false;
end
for i=2:nargs
  vi = varargin{i};
  if ~isempty(vi) && (isGPUArray ~= isa(vi,'parallel.gpu.GPUArray')) 
    error('nnet:sim:Composite','Data values must be all gpuArray or not.');
  end
end

% Fill in missing data consistent with type
if isComposite
  emptyCell = Composite;
  for i=1:numel(emptyCell)
    emptyCell{i} = {};
  end
else
  emptyCell = {};
end
if (nargs < 1), X = emptyCell; else X = varargin{1}; end
if (nargs < 2), T = emptyCell; else T = varargin{2}; end
if (nargs < 3), Xi = emptyCell; else Xi = varargin{3}; end
if (nargs < 4), Ai = emptyCell; else Ai = varargin{4}; end
if (nargs < 5), EW = emptyCell; else EW=varargin{5}; end
if isComposite
  for i=1:numel(X)
    if ~exist(X,i), X{i} = {}; end
    if ~exist(T,i), T{i} = {}; end
    if ~exist(Xi,i), Xi{i} = {}; end
    if ~exist(Ai,i), Ai{i} = {}; end
    if ~exist(EW,i), EW{i} = {}; end
  end
end

% Train
if ~feval(net.trainFcn,'supportsCalcModes');
  % Train without advanced calculation modes
  if isComposite
    error('nnet:train:data',['Training function ' net.trainFcn ' does not support Composite data.']);
  end
  if isGPUArray
    error('nnet:train:data',['Training function ' net.trainFcn ' does not support gpuArray data.']);
  end
  [net,data,tr,err] = nntraining.setup(net,net.trainFcn,X,Xi,Ai,T,EW,true);
  if ~isempty(err), nnerr.throw('Args',err), end
  hints = nn7.netHints(net);
  data.Pc = nn7.pc(net,data.X,data.Xi,data.Q,data.TS,hints);
  data.Pd = nn7.pd(net,data.Pc,data.Q,data.TS,hints);
  hints = nn7.dataHints(net,data,hints);
  [net,tr] = feval(net.trainFcn,'apply',net,tr,data,hints,net.trainParam);
  
else  
  % Check Data and Network
  if isComposite
    spmd
      [~,rawData,trComp,err] = nntraining.setup(net,net.trainFcn,X,Xi,Ai,T,EW,false);
      if ~isempty(err), nnerr.throw('Args',err), end
      QTSs = rawData.Q * rawData.TS;
    end
    QTSs = nnParallel.composite2Array(QTSs);
    i = find(QTSs>0,1);
    if isempty(i)
      tr = [];
      return;
    end
    tr = trComp{i};
  else
    [net,rawData,tr,err] = nntraining.setup(net,net.trainFcn,X,Xi,Ai,T,EW,~isGPUArray);
    if ~isempty(err), nnerr.throw('Args',err), end
    if ((rawData.Q == 0) || (rawData.TS == 0));
      tr = [];
      return;
    end
  end

  % Setup simulation/training calculation mode, network, data and hints
  [calcMode,calcNet,calcData,calcHints,net,resourceText] = nncalc.setup1(calcMode,net,rawData);
  if ~isempty(resourceText)
    disp(' ')
    disp('Computing Resources:')
    nntext.disp(resourceText)
    disp(' ')
  end
  trainFcn = str2func(net.trainFcn);
  
  % Train in Parallel or Single mode
  isParallel = isa(calcMode,'Composite');
  if isParallel
    spmd
      [calcLib,calcNet] = nncalc.setup2(calcMode,net,calcData,calcHints);
      ws = warning('off','parallel:gpu:kernel:NullPointer');
      [calcNet,tr] = trainFcn('apply',net,rawData,calcLib,calcNet,tr);
      warning(ws);
      if (calcMode.isMainWorker)
        WB = calcMode.getwb(calcNet,calcHints);
      end
      if (labindex == 1), mainWorkerInd = calcLib.mainWorkerInd; end
    end
    mainWorkerInd = mainWorkerInd{1};
    WB = WB{mainWorkerInd};
    tr = tr{mainWorkerInd};
  else
    [calcLib,calcNet] = nncalc.setup2(calcMode,calcNet,calcData,calcHints);
    ws = warning('off','parallel:gpu:kernel:NullPointer');
    [calcNet,tr] = trainFcn('apply',net,rawData,calcLib,calcNet,tr);
    warning(ws);
    WB = calcMode.getwb(calcNet,calcHints);
  end

  % Finalize Network and Training Record
  net = setwb(net,WB);
end

net = network(net);
tr = nntraining.tr_clip(tr);
if isfield(tr,'perf')
  tr.best_perf = tr.perf(tr.best_epoch+1);
end
if isfield(tr,'vperf')
  tr.best_vperf = tr.vperf(tr.best_epoch+1);
end
if isfield(tr,'tperf')
  tr.best_tperf = tr.tperf(tr.best_epoch+1);
end

% NNET 5.1 Compatibility
if nargout > 2
  [out3,out5,out6] = sim(net,X,Xi,Ai,T);
  out4 = gsubtract(T,out3);
end

