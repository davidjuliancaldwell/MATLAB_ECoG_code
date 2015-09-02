function z = gamprod(w,varargin)
%GAMPROD Gamma product test weight function

% Copyright 2010-2012 The MathWorks, Inc.

% NNET 7.0 Backward Compatibility
% WARNING - This functionality may be removed in future versions
if ischar(w)
  z = nnet7.weight_fcn('nntest.gamprod',w,varargin{:});
  return
end

% Apply
z = nntest.gamprod.apply(w,varargin{:});
