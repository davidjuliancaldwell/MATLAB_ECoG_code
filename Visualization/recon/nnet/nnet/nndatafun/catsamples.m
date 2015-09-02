function y = catsamples(varargin)
%CATSAMPLES Concatenate neural network data samples.
%
%  <a href="matlab:doc catsamples">catsamples</a>(X1,X2,...,XN) concatenates each NN data value Xi,
%  into a single NN data value, along the sample dimension.
%
%  If all Xi are matrices this operation is the same as [X1,X2,...,XN];
%
%  If any Xi is a cell array the result is a cell array with the same
%  dimensions as each Xi cell array (or 1x1 if any are a matrix). Each
%  {i,j} element is defined as [X1{i,j}, X2{i,j}, ... ,XN{i,j}.
%
%  This code concatenates the elements of two matrix data values:
%
%    x1 = [1 2 3; 4 7 4]
%    x2 = [5 8 2; 4 7 6]
%    y = <a href="matlab:doc catsamples">catsamples</a>(x1,x2)
%
%  This code concatenates the elements of two cell array data values:
%
%    x1 = {[1:3; 4:6] [7:9; 10:12]; [13:15] [16:18]}
%    x2 = {[2 1 3; 5 4 1] [4 5 6; 9 4 8]; [2 5 4] [9 7 5]}
%    y = <a href="matlab:doc catsamples">catsamples</a>(x1,x2)
%
%  <a href="matlab:doc catsamples">catsamples</a>(X1,X2,...XN,'pad',v) can concatenate data with different
%  numbers of timesteps.  It does this by padding out the shorter time
%  series data with the scalar V value so they match the longest sequence.
%  If V is omitted the value NaN is used.
%
%    x1 = {1 2 3 4 5};
%    x2 = {10 11 12};
%    y = <a href="matlab:doc catsamples">catsamples</a>(x1,x2,'pad')
%
%  See also NUMSAMPLES, GETSAMPLES, SETSAMPLES, NNDATA, NNDIMENSIONS

% Copyright 2010 The MathWorks, Inc.

% Padding
padding = false;
padValue = 0;
if (nargin >= 1) &&  ischar(varargin{end}) && strcmp('pad',varargin{end})
  padding = true;
  padValue = NaN;
  varargin = varargin(1:(end-1));
elseif (nargin >= 2) && ischar(varargin{end-1}) && strcmp('pad',varargin{end-1})
  padding = true;
  padValue = nntype.num_scalar('format',varargin{end});
  varargin = varargin(1:(end-2));
end

% Checks
numData = length(varargin);
if numData == 0, y = {}; return; end
wasMatrix = true;
for i=numData:-1:1
  xi = varargin{i};
  wasMatrix = wasMatrix && ~iscell(xi);
  [varargin{i},err] = nntype.data('format',xi);
  if ~isempty(err),nnerr.throw(nnerr.value(err,['Argument ' num2str(i)])); end
end

% Check dimensions
padTS = 0;
if padding
  for i=1:numData
    padTS = max(padTS,nnfast.numtimesteps(varargin{i}));
  end
  for i=1:numData
    [N,Q,TS] = nnfast.nnsize(varargin{i});
    if (TS < padTS)
      varargin{i} = nnfast.cattimesteps(varargin{i},nndata(N,Q,padTS-TS,padValue));
    end
  end
end
[N,~,TS,S] = nnfast.nnsize(varargin{1});
for i=2:numData
  [ni,~,tsi,si] = nnfast.nnsize(varargin{i});
  if (tsi~=TS) || (si~=S) || any(ni ~= N)
    error(message('nnet:NNData:BadDim'));
  end
end

% Concatenate      
y = nnfast.catsamples(varargin{:});

% Matrix format
if wasMatrix && (numel(y)==1), y = y{1}; end
