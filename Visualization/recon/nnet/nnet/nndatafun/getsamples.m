function y = getsamples(x,ind)
%GETSAMPLES Get samples from neural network data.
%
%  <a href="matlab:doc getsamples">getsamples</a>(X,IND) returns the samples in X with indices IND, where
%  X in NN data in either matrix or cell form.
%
%  If X is a matrix the result is the IND columns of X.
%
%  If X is a cell array the result is a cell array the same size as X,
%  whose elements are the IND columns of the matrices in X.
%
%  This code gets samples 1 and 3 from matrix data:
%
%    x = [1 2 3; 4 7 4]
%    y = <a href="matlab:doc getsamples">getsamples</a>(x,[1 3])
%
%  This code gets samples 1 and 3 from cell array data:
%
%    x = {[1:3; 4:6] [7:9; 10:12]; [13:15] [16:18]}
%    y = <a href="matlab:doc getsamples">getsamples</a>(x,[1 3])
%
%  See also NUMSAMPLES, SETSAMPLES, CATSAMPLES, ISNNDATA, NNDIMENSIONS

% Copyright 2010 The MathWorks, Inc.

% Check arguments
if nargin < 1, error(message('nnet:Args:NotEnough')); end
wasMatrix = ~iscell(x);
[x,err] = nntype.data('format',x);
if ~isempty(err), nnerr.throw(nnerr.value(err,'X')); end
err = nntype.index_row_unique('check',ind);
if ~isempty(err), nnerr.throw(nnerr.value(err,'Indices')); end

% Calculate
y = nnfast.getsamples(x,ind);

% Matrix format
if wasMatrix && ~isempty(y), y = y{1}; end
