function z = dotprod3(w,varargin)
%DOTPROD3 Test Dot product weight function 3.

% Copyright 2010-2012 The MathWorks, Inc.

% NNET 7.0 Backward Compatibility
% WARNING - This functionality may be removed in future versions
if ischar(w)
  z = nnet7.weight_fcn('nntest.dotprod3',w,varargin{:});
  return
end

% Apply
z = nntest.dotprod3.apply(w,varargin{:});
