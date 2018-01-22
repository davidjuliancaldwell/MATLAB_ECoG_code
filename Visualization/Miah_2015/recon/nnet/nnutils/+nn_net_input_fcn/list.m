function fcns = list(test_flag)

% Copyright 2012 The MathWorks, Inc.

if nargin < 1, test_flag = false; end

fcns = nnfcn.siblings('netsum');

if test_flag
  % Test Functions
  fcns = [fcns {'nntestfun.netsum2'}];
end
