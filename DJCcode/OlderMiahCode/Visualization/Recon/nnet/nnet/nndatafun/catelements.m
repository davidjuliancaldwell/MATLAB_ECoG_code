function y = catelements(varargin)
%CATELEMENTS Concatenate neural network data elements.
%
%  <a href="matlab:doc catelements">catelements</a>(X1,X2,...,XN) concatenates each NN data value Xi,
%  into a single NN data value, along the element dimension.
%
%  If all Xi are matrices this operation is the same as [X1;X2;...;XN];
%
%  If any Xi is a cell array the result is a cell array with the same
%  dimensions as each Xi cell array (or 1x1 if any are a matrix). Each
%  {i,j} element is defined as [X1{i,j}; X2{i,j}; ... ;XN{i,j}.
%
%  This code concatenates the elements of two matrix data values:
%
%    x1 = [1 2 3; 4 7 4]
%    x2 = [5 8 2; 4 7 6; 2 9 1]
%    y = <a href="matlab:doc catelements">catelements</a>(x1,x2)
%
%  This code concatenates the elements of two cell array data values:
%
%    x1 = {[1:3; 4:6] [7:9; 10:12]; [13:15] [16:18]}
%    x2 = {[2 1 3] [4 5 6]; [2 5 4] [9 7 5]}
%    y = <a href="matlab:doc catelements">catelements</a>(x1,x2)
%
%  See also NUMELEMENTS, GETELEMENTS, SETELEMENTS, NNDATA, NNDIMENSIONS

% Copyright 2010 The MathWorks, Inc.

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
[~,Q,TS,S] = nnfast.nnsize(varargin{1});
for i=2:numData
  [~,qi,tsi,si] = nnfast.nnsize(varargin{i});
  if (tsi~=TS) || (si~=S) || (qi ~= Q)
    error(message('nnet:NNData:BadDim'));
  end
end

% Concatenate      
y = nnfast.catelements(varargin{:});

% Matrix format
if wasMatrix && (numel(y)==1), y = y{1}; end
