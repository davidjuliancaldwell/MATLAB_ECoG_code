function z = dotprod2(w,varargin)
%DOTPROD2 Test Dot product weight function 2.

% Copyright 2010-2012 The MathWorks, Inc.

% NNET 7.0 Backward Compatibility
% WARNING - This functionality may be removed in future versions
if ischar(w)
  z = nnet7.weight_fcn('nntest.dotprod2',w,varargin{:});
  return
end

% Apply
z = nntest.dotprod2.apply(w,varargin{:});
