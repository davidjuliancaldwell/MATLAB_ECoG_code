function fcns = list(test_flag)

% Copyright 2012 The MathWorks, Inc.

if nargin < 1, test_flag = false; end

fcns = nnfcn.siblings('mapminmax');

if test_flag
  % Test Functions
  fcns = [fcns {}];
end
