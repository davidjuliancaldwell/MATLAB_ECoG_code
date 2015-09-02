function y = settimesteps(x,ind,v)
%SETTIMESTEPS Set neural network data timesteps.
%
%  <a href="matlab:doc settimesteps">settimesteps</a>(X,IND,V) returns the X with the timesteps with indices IND
%  set to V, where X and V are NN data in either matrix or cell form.
%
%  If X is a matrix IND may only be 1, which will return V, or [] which
%  will return X.
%
%  This code sets timestep 2 of cell array data:
%
%    x = {[1:3; 4:6] [7:9; 10:12]; [13:15] [16:18]}
%    v = {[20:22; 23:25]; [25:27]}
%    y = <a href="matlab:doc settimesteps">settimesteps</a>(x,2,v)
%
%  See also NUMTIMESTEPS, SETTIMESTEPS, CATTIMESTEPS, NNDATA, NNSIZE

% Copyright 2010 The MathWorks, Inc.

% Check arguments
if nargin < 1, error(message('nnet:Args:NotEnough')); end
wasMatrix = ~iscell(x);
x = nntype.data('format',x,'Original data');
nntype.index_vector('check',ind,'Indices');
v = nntype.data('format',v,'Set data');

% Check dimensions
[Nx,Qx,TSx,Sx] = nnfast.nnsize(x);
[Nv,Qv,TSv,Sv] = nnfast.nnsize(v);
if (Qx~=Qv) || (Sx~=Sv) || any(Nx~=Nv)
  error(message('nnet:NNData:DimOriginalValueMismatch'));
end
if TSv ~= length(ind)
  error(message('nnet:NNData:NumIndicesTimestepsMismatch'));
end
if any(ind < 1) || any(ind > TSx)
  error(message('nnet:NNData:IndicesOutOfBounds'));
end

% Set
y = nnfast.settimesteps(x,ind,v);

% Matrix format
if wasMatrix, y = y{1}; end
