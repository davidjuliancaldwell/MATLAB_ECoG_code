function y = cattimesteps(varargin)
%CATTIMESTEPS Concatenate neural network data timesteps.
%
%  <a href="matlab:doc cattimesteps">cattimesteps</a>(X1,X2,...,XN) returns concatenates each NN data value Xi,
%  into a single NN data value, along the timestep dimension.
%
%  If any Xi are matrices they are put in a cell array {Xi} before all
%  values are cell array concatenated as [X1 X2 ... XN].
%
%  This code concatenates the elements of two matrix data values:
%
%    x1 = [1 2 3; 4 7 4]
%    x2 = [5 8 2; 4 7 6]
%    y = <a href="matlab:doc cattimesteps">cattimesteps</a>(x1,x2)
%
%  This code concatenates the elements of two cell array data values:
%
%    x1 = {[1:3; 4:6] [7:9; 10:12]; [13:15] [16:18]}
%    x2 = {[2 1 3; 5 4 1] [4 5 6; 9 4 8]; [2 5 4] [9 7 5]}
%    y = <a href="matlab:doc cattimesteps">cattimesteps</a>(x1,x2)
%
%  See also NUMTIMESTEPS, GETTIMESTEPS, SETTIMESTEPS, NNDATA, NNDIMENSIONS

% Copyright 2010 The MathWorks, Inc.

% TODO - Pad shorter time-series
% TODO - create function to pad time-series

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
[N,Q,~,S] = nnfast.nnsize(varargin{1});
for i=2:numData
  [ni,qi,~,si] = nnfast.nnsize(varargin{i});
  if (qi~=Q) || (si~=S) || any(ni ~= N)
    error(message('nnet:NNData:BadDim'));
  end
end

% Concatenate
y = cat(2,varargin{:});

% Matrix format
if wasMatrix && (numel(y)==1), y = y{1}; end
