function fcns = list(test_flag)

% Copyright 2012 The MathWorks, Inc.

if nargin < 1, test_flag = false; end

fcns = nnfcn.siblings('mse');

if test_flag
  % Obsolete Functions
  fcns = [fcns; {'msereg';'mseregec';'msne';'msnereg'}];
end
