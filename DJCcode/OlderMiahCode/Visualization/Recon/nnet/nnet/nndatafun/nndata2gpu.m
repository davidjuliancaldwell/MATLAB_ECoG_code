function [y,Q,N,TS] = nndata2gpu(x,precision,alignment)
%NNDATA2GPU Formats neural data for efficient GPU training or simulation.
%
%  Training and simulation of neural networks requires that matrices be
%  transposed, and do not require but are more efficient when the column
%  length is padded so that each column is memory aligned.  This function
%  performs both transforms on neural network data and copies it to the
%  current GPU.
%
%  [Y,Q] = <a href="matlab:doc nndata2gpu">nndata2gpu</a>(X) takes an NxQ matrx X of Q N-element column vectors and
%  returns it in a form for neural network training and simulation on the
%  current gpuDevice.
%  
%  The NxQ matrix becomes a QQxN gpuArray where QQ is Q rounded up to the
%  next multiple of 32. The extra rows (Q+1):QQ are filled with NaN values.
%  The gpuArray will have the same precision, 'single' or 'double' as X.
%
%  [Y,Q,N,TS] = <a href="matlab:doc nndata2gpu">nndata2gpu</a>(X) can also take an MxTS cell array of M signals
%  over TS timesteps.  Each element of X{i,ts} should be an NixQ matrix of Q
%  Ni-element vectors representing the ith signal vector at timestep ts,
%  across all Q time series.
%
%  In this case the gpuArray Y returned will be QQx(sum(Ni)*TS).
%
%  Dimensions Ni, Q and TS are also returned so they can be used with
%  <a href="matlab:doc gpu2nndata">gpu2nndata</a> to perform the reverse formatting.
%
%  <a href="matlab:doc nndata2gpu">nndata2gpu</a>(X,PRECISION) specifies the precision of the gpuArray which
%  can be the default 'double' or 'single' or any other GPU compatible
%  precision.
%
%  Here a matrix is copied to the GPU and back:
%
%    x = rand(5,6)
%    [y,q] = <a href="matlab:doc nndata2gpu">nndata2gpu</a>(x)
%    x2 = <a href="matlab:doc gpu2nndata">gpu2nndata</a>(y,q)
%
%  Here a neural network cell array data representing 4 time series,
%  each consisting of 5 timesteps of 2-element and 3-element signals.
%
%    x = nndata([2;3],4,5)
%    [y,q,n,ts] = <a href="matlab:doc nndata2gpu">nndata2gpu</a>(x)
%    x2 = <a href="matlab:doc gpu2nndata">gpu2nndata</a>(y,q,n,ts)
%
% See also GPU2NNDATA.

% Copyright 2012 The MathWorks, Inc.

if ~nnDependency.distCompAvailable
  error('nnet:nndata2gpu:PCTAvailable','Parallel Computing Toolbox is not available.');
end
if ~nnGPU.isSupported
  error('nnet:nndata2gpu:GPUAvailalbe','Parallel Computing Toolbox gpuDevice is not selected.');
end

% Precision
if nargin < 2
  if ~isempty(x) && ~iscell(x)
    precision = class(x);
  elseif ~isempty(x) && ~isempty(x{1})
    precision = class(x{1}(1));
  else
    precision = 'double';
  end
end

% Ensure x is in cell form
if ~iscell(x), x = {x}; end

% Alignment
if nargin < 3
  alignment = 32;
end

% NN Data dimensions
[N,Q,TS,M] = nnsize(x);

% Round sample number up to next alignment
% Extra rows will befilled with NaN values if floating point,
% or zeros if integer or other precision.
QQ = ceil(Q/alignment)*alignment;
if ~isfinite(QQ), QQ = 0; end
if strcmp(precision,'single') || strcmp(precision,'double')
  y = nan(QQ,sum(N)*TS,precision);
else
  y = zeros(QQ,sum(N)*TS,precision);
end

% Empty case
if isempty(y)
  y = gpuArray(y);
  return
end

% Combine transposed data
offsets = cumsum([0; N(1:(end-1))]);
rows = 1:Q;
for i=1:M
  for ts=1:TS
    Ni = N(i);
    cols = offsets(i)*TS + Ni*(ts-1) + (1:Ni);
    y(rows,cols) = x{i,ts}';
  end
end

% Move data to GPU
y = gpuArray(y);
