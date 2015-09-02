function y = getelements(x,ind)
%GETELEMENTS Get neural network data elements.
%
%  <a href="matlab:doc getelements">getelements</a>(X,IND) returns the elements in X with indices IND, where
%  X in NN data in either matrix or cell form.
%
%  If X is a matrix the result is the IND rows of X.
%
%  If X is a cell array the result is a cell array Y with as many columns
%  as X, whose elements Y(1,i) are matrices containing the IND rows of
%  [X{:,i}].
%
%  This code gets elements 1 and 3 from matrix data:
%
%    x = [1 2 3; 4 7 4]
%    y = <a href="matlab:doc getelements">getelements</a>(x,[1 3])
%
%  This code gets elements 1 and 3 from cell array data:
%
%    x = {[1:3; 4:6] [7:9; 10:12]; [13:15] [16:18]}
%    y = <a href="matlab:doc getelements">getelements</a>(x,[1 3])
%
%  See also NUMELEMENTS, SETELEMENTS, CATELEMENTS, ISNNDATA, NNDIMENSIONS

% Copyright 2010 The MathWorks, Inc.

% Check arguments
if nargin < 1, error(message('nnet:Args:NotEnough')); end
wasMatrix = ~iscell(x);
[x,err] = nntype.data('format',x);
if ~isempty(err), nnerr.throw(nnerr.value(err,'X')); end
err = nntype.index_vector('check',ind);
if ~isempty(err), nnerr.throw(nnerr.value(err,'Indices')); end

% Calculate
y = nnfast.getelements(x,ind);

% Matrix format
if wasMatrix && ~isempty(y), y = y{1}; end
