function x = gpu2nndata(y,Q,N,TS)
%GPU2NNDATA Reformats neural data back from GPU.
%
%  Training and simulation of neural networks requires that matrices be
%  transposed, and do not require but are more efficient when the column
%  length is padded so that each column is memory aligned.  This function
%  copies data back from the current GPU and reverses this transform. It
%  can be used on data formated with <a href="matlab:doc nndata2gpu">nndata2gpu</a> or the results of network
%  simulation.
%
%  X = <a href="matlab:doc gpu2nndata">gpu2nndata</a>(Y,Q) copies the QQxN gpuArray Y into RAM, takes the first
%  Q rows and transposes the result to get X an NxQ matrix representing Q
%  N-element vectors.
%
%  X = <a href="matlab:doc gpu2nndata">gpu2nndata</a>(Y) calculates Q as the index of the last row in Y that
%  is not all NaN values (those rows were added to pad Y for efficient
%  GPU computation by <a href="matlab:doc nndata2gpu">nndata2gpu</a>).  Y is then transformed as before.
%
%  X = <a href="matlab:doc gpu2nndata">gpu2nndata</a>(Y,Q,N,TS) takes a QQx(N*TS) gpuArray where N is a vector of
%  signal sizes, Q is the number of samples (less than or equal to the
%  number of rows after alignment padding QQ), and TS is the number of
%  timesteps.
%
%  The gpuArray Y is copied back into RAM, the first Q rows are taken, and
%  then it is divided up and transposed into an MxTS cell array, where M
%  is the number of elements in N.  Each X{i,ts} is an N(i)xQ matrix.
%
%  Here a matrix is copied to the GPU and back:
%
%    x = rand(5,6)
%    [y,q] = <a href="matlab:doc nndata2gpu">nndata2gpu</a>(x)
%    x = <a href="matlab:doc gpu2nndata">gpu2nndata</a>(y,q)
%
%  Here a neural network cell array data representing 4 time series,
%  each consisting of 5 timesteps of 2-element and 3-element signals.
%
%    x2 = nndata([2;3],4,5)
%    [y,q,n,ts] = <a href="matlab:doc nndata2gpu">nndata2gpu</a>(x)
%    x2 = <a href="matlab:doc gpu2nndata">gpu2nndata</a>(y,q,n,ts)
%
% See also NNDATA2GPU.

% Copyright 2012 The MathWorks, Inc.

if ~nnDependency.distCompAvailable
  error('nnet:nndata2gpu:PCTAvailable','Parallel Computing Toolbox is not available.');
end
if ~nnGPU.isSupported
  error('nnet:nndata2gpu:GPUAvailalbe','Parallel Computing Toolbox gpuDevice is not selected.');
end

% Get data from GPU
y = gather(y);

% Default Q removes last NaN rows
if nargin < 2
  Q = find(all(~isnan(y),2),1,'last');
  if isempty(Q), Q = 0; end
end

% Return matrix
if nargin < 3
  x = y(1:Q,:)';
  return
end

% Separate transposed data
if nargin < 4, TS = 1; end
M = numel(N);
x = cell(M,TS);
offsets = cumsum([0; N(1:(end-1))]);
rows = 1:Q;
for i=1:M
  for ts=1:TS
    Ni = N(i);
    cols = offsets(i)*TS + Ni*(ts-1) + (1:Ni);
    x{i,ts} = y(rows,cols)';
  end
end
