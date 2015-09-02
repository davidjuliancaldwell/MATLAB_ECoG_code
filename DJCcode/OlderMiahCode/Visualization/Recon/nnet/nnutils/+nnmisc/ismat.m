function [varargout] = ismat(varargin)
%ISNNMATRIX Returns true for neural network data in matrix form.
%
%  ISNNMATRIX(X1,X2,...) returns true if X1, X2, etc., are all two
%  dimensional logical or real numeric two dimensional matrices.
%
%  [F1,F2,...] = ISNNMATRIX(X1,X2,...) returns flags Fi indicating if the
%  corresponding Xi's are two dimensional logical or  real numeric matrix.

% Copyright 2010 The MathWorks, Inc.

if (nargout > 1) && (nargin ~= nargout)
  error(message('nnet:Args:NumInOutMismatch'));
end

flags = cell(1,nargin);
for i=1:nargin
  flags{i} = nntype.matrix_data('isa',varargin{i});
end
if nargout < 2
  varargout = { all([flags{:}]) };
else
  varargout = flags;
end
