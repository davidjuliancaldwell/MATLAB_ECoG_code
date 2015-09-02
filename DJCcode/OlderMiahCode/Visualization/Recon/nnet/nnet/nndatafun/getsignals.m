function y = getsignals(x,ind)
%GETSIGNALS Get signals from neural network data.
%
%  <a href="matlab:doc getsignals">getsignals</a>(X,IND) returns the signals in X with indices IND, where
%  X in NN data in either matrix or cell form.
%
%  If X is a matrix IND may only be 1, which will return X, or [] which
%  will return an empty matrix.
%
%  If X is a cell array the result is the IND rows of X.
%
%  This code gets signal 2 from cell array data:
%
%    x = {[1:3; 4:6] [7:9; 10:12]; [13:15] [16:18]}
%    y = <a href="matlab:doc getsignals">getsignals</a>(x,2)
%
%  See also NUMSIGNALS, SETSIGNALS, CATSIGNALS, ISNNDATA, NNDIMENSIONS

% Copyright 2010 The MathWorks, Inc.

% TODO - one data only, for this function and fast function


% Check arguments
if nargin < 1, error(message('nnet:Args:NotEnough')); end
wasMatrix = ~iscell(x);
[x,err] = nntype.data('format',x);
if ~isempty(err), nnerr.throw(nnerr.value(err,'X')); end
err = nntype.index_row_unique('check',ind);
if ~isempty(err), nnerr.throw(nnerr.value(err,'Indices')); end

% Get
y = nnfast.getsignals(x,ind);

% Matrix format
if wasMatrix && (numel(y)==1), y = y{1}; end

