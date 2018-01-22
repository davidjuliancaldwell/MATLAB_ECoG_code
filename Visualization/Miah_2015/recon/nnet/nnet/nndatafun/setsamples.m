function y = setsamples(x,ind,v)
%SETSAMPLES Set neural network data samples.
%
%  <a href="matlab:doc setsamples">setsamples</a>(X,IND,V) returns the X with the samples with indices IND
%  set to V, where X and V are NN data in either matrix or cell form.
%
%  This code sets samples 1 and 3 of matrix data:
%
%    x = [1 2 3; 4 7 4]
%    v = [10 11; 12 13];
%    y = <a href="matlab:doc setsamples">setsamples</a>(x,[1 3],v)
%
%  This code sets samples 1 and 3 of cell array data:
%
%    x = {[1:3; 4:6] [7:9; 10:12]; [13:15] [16:18]}
%    v = {[20 21; 22 23] [24 25; 26 27]; [28 29] [30 31]}
%    y = <a href="matlab:doc setsamples">setsamples</a>(x,[1 3],v)
%
%  See also NUMSAMPLES, SETSAMPLES, CATSAMPLES, NNDATA, NNSIZE

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
if (TSv~=TS) || (Sv~=S) || any(Nv~=N)
  error(message('nnet:NNData:ValueSetMismatch'));
end
if Qv ~= length(ind)
  error(message('nnet:NNData:NumIndicesSamplesMismatch'));
end
if any(ind < 1) || any(ind > Q)
  error(message('nnet:NNData:IndicesOutOfBounds'));
end

% Set
y = nnfast.setsamples(x,ind,v);

% Matrix format
if wasMatrix, y = y{1}; end
