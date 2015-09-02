function y = setelements(x,ind,v)
%SETELEMENTS Set neural network data elements.
%
%  <a href="matlab:doc setelements">setelements</a>(X,IND,V) returns the X with the elements with indices IND
%  set to V, where X and V are NN data in either matrix or cell form.
%
%  If V is a cell array, the total number of rows in a column of its
%  matrices must equal the number of indices in IND. In other words,
%  size([V(:,1)]) must equal length(IND).
%
%  This code sets elements 1 and 3 of matrix data:
%
%    x = [1 2; 3 4; 5 6]
%    v = [10 11; 12 13];
%    y = <a href="matlab:doc setelements">setelements</a>(x,[1 3],v)
%
%  This code sets elements 1 and 3 of cell array data:
%
%    x = {[1:3; 4:6] [7:9; 10:12]; [13:15] [16:18]}
%    v = {[20 21 22; 23 24 25] [26 27 28; 29 30 31]}
%    y = <a href="matlab:doc setelements">setelements</a>(x,[1 3],v)
%
%  See also NUMELEMENTS, SETELEMENTS, CATELEMENTS, NNDATA, NNSIZE

% Copyright 2010-2011 The MathWorks, Inc.

% Check arguments
if nargin < 1, error(message('nnet:Args:NotEnough')); end
wasMatrix = ~iscell(x);
x = nntype.data('format',x,'Original data');
nntype.index_vector_unique('check',ind,'Indices');
v = nntype.data('format',v,'Set data');

% Check dimensions
[N,Q,TS,S] = nnfast.nnsize(x);
[Nv,Qv,TSv,Sv] = nnfast.nnsize(v);
if (TSv~=TS) || any(Qv~=Q)
  error(message('nnet:NNData:ValueSetMismatch'));
end
if Sv ~= 1
  v2 = cell(1,TS);
  for ts=1:TS
    v2{1,ts} = cat(1,v{:,ts});
  end
  Nv = sum(Nv);
end
if Nv ~= length(ind)
  error(message('nnet:NNData:IndicesValueMismatch'));
end
if any(ind < 1) || any(ind > sum(N))
  error(message('nnet:NNData:IndicesOutOfBounds'));
end

% Get
y = nnfast.setelements(x,ind,v);

% Matrix format
if wasMatrix, y = y{1}; end
