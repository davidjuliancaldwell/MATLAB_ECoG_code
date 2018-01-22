function a = tansig2(n,varargin)
%TANSIG2 Test symmetric sigmoid transfer function with parameters.

% Copyright 2010-2012 The MathWorks, Inc.

% NNET 7.0 Compatibility
% WARNING - This functionality may be removed in future versions
if ischar(n)
  a = nnet7.transfer_fcn('nntest.tansig2',n,varargin{:});
  return
end

% Apply
a = nntest.tansig2.apply(n,varargin{:});
