function y = setsignals(x,ind,v)
%SETSIGNALS Set neural network data signals.
%
%  <a href="matlab:doc setsignals">setsignals</a>(X,IND,V) returns the X with the signals with indices IND
%  set to V, where X and V are NN data in either matrix or cell form.
%
%  If X is a matrix IND may only be 1, which will return V, or [] which
%  will return X.
%
%  This code sets signal 2 of cell array data:
%
%    x = {[1:3; 4:6] [7:9; 10:12]; [13:15] [16:18]}
%    v = {[20:22] [23:25]}
%    y = <a href="matlab:doc setsignals">setsignals</a>(x,2,v)
%
%  See also NUMSIGNALS, SETSIGNALS, CATSIGNALS, NNDATA, NNSIZE

% Copyright 2010 The MathWorks, Inc.

% Check arguments
if nargin < 1, error(message('nnet:Args:NotEnough')); end
wasMatrix = ~iscell(x);
x = nntype.data('format',x,'Original data');
nntype.index_vector_unique('check',ind,'Indices');
v = nntype.data('format',v,'Set data');

% Check dimensions
[N,Q,TS,S] = nnfast.nnsize(x);
[Nv,Qv,TSv,Sv] = nnfast.nnsize(v);
if (Qv~=Q) || (TSv~=TS)
  error(message('nnet:NNData:DimOriginalValueMismatch'));
end
if Sv ~= length(ind)
  error(message('nnet:NNData:NumIndicesSignalsMismatch'));
end
if any(ind < 1) || any(ind > S)
  error(message('nnet:NNData:IndicesOutOfBounds'));
end
if any(Nv ~= N(ind))
  error(message('nnet:NNData:DimOriginalValueMismatch'));
end

% Set
y = nnfast.setsignals(x,ind,v);

% Matrix format
if wasMatrix, y = y{1}; end
