function data = formatData(data1,hints)

% Copyright 2012 The MathWorks, Inc.

% Dimensions
data.Q = data1.Q;
data.QAligned = hints.QAligned;
data.TS = data1.TS;

emptyGPUArray = nndata2gpu([],hints.precision);

% Simulation Data
if isa(data1.X,'parallel.gpu.GPUArray')
  data.X = data1.X;
  data.Xi = data1.Xi;
  data.Ai = data1.Ai;
  data.Pc = data1.Pc;
  data.Pd = data1.Pd;
else
  if ~hints.doDelayedInputs
    disp('UNSUPPORTED');
    return
  elseif ~hints.doProcessInputs
    data.X = emptyGPUArray;
    data.Xi = emptyGPUArray;
    data.Pc = nndata2gpu(data1.Pc,hints.precision);
    data.Pd = emptyGPUArray;
  else
    data.X = nndata2gpu(data1.X,hints.precision);
    data.Xi = nndata2gpu(data1.Xi,hints.precision);
    data.Pc = emptyGPUArray;
    data.Pd = emptyGPUArray;
  end
end

% Allocate Ac (used to pass in Ai, calculate A values, and return Af)
if isa(data1.X,'parallel.gpu.GPUArray')
  NLE = sum(hints.layer_sizes);
  NLD = hints.numLayerDelays;
  data.Ac = gpuArray(zeros(data.QAligned,NLE*(NLD+data.TS),hints.precision));
  Aicols = NLD*NLE;
  if (NLD * NLE) > 0
    data.Ac(:,1:Aicols) = data.Ai;
  end
else
  A = nndata(hints.layer_sizes,data.Q,data.TS,0);
  data.Ac = nndata2gpu([data1.Ai A],hints.precision);
end

% Allocate Y
data.Y = gpuArray(nan(data.QAligned,sum(hints.output_sizes)*data.TS,hints.precision));

% Performance Data
if isfield(data1,'T')
  
  if isa(data1.X,'parallel.gpu.GPUArray')
    data.T = data1.T;
    data.EW = data1.EW;
  else
    data.T = nndata2gpu(data1.T,hints.precision);
    data.EW = nndata2gpu(data1.EW,hints.precision,hints.Q_EW_Aligned);
  end
  
  if isfield(data1,'train')
    m = combine_masks(data1.train.mask,data1.val.mask,data1.test.mask);
    data.masks = nndata2gpu(gsubtract(m,1),'int8',data.QAligned);
  end
end

function m = combine_masks(varargin)
[N,Q,TS] = nnsize(varargin{1});
m = nndata(N,Q,TS,0);
for i=1:numel(m)
  mi = m{i};
  for j=1:numel(varargin)
    mji = varargin{j}{i};
    mi(isfinite(mji)) = j;
  end
  m{i} = mi;
end
