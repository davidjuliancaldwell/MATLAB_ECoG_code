function y = gettimesteps(x,ind)
%GETTIMESTEPS Get neural network data timesteps.
%
%  <a href="matlab:doc gettimesteps">gettimesteps</a>(X,IND) returns the timesteps in X with indices IND, where
%  X in NN data in either matrix or cell form.
%
%  If X is a matrix IND may only be 1, which will return X, or [] which
%  will return an empty matrix.
%
%  If X is a cell array the result is the IND columns of X.
%
%  This code gets timestep 2 from cell array data:
%
%    x = {[1:3; 4:6] [7:9; 10:12]; [13:15] [16:18]}
%    y = <a href="matlab:doc gettimesteps">gettimesteps</a>(x,2)
%
%  See also NUMTIMESTEPS, SETTIMESTEPS, CATTIMESTEPS, ISNNDATA, NNDIMENSIONS

% Copyright 2010 The MathWorks, Inc.

% Check arguments
if nargin < 1, error(message('nnet:Args:NotEnough')); end
wasMatrix = ~iscell(x);
[x,err] = nntype.data('format',x);
if ~isempty(err), nnerr.throw(nnerr.value(err,'X')); end
err = nntype.index_row_unique('check',ind);
if ~isempty(err), nnerr.throw(nnerr.value(err,'Indices')); end

% Calculate
y = nnfast.gettimesteps(x,ind);

% Matrix format
if wasMatrix && ~isempty(y), y = y{1}; end

