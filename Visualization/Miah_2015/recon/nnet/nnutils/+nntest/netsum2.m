function n=netsum2(varargin)
%NETSUM2 Sum net input function with parameters.

% Copyright 2012 The MathWorks, Inc.

% NNET 7.0 Compatibility
% WARNING - This functionality may be removed in future versions
if ischar(varargin{1})
  n = nnet7.net_input_fcn('nntest.netsum2',varargin{:});
  return
end

% Apply
n = nntest.netsum2.apply(varargin{:});
