function a = apply(n,param)

% Copyright 2012 The MathWorks, Inc.

a = 2*param.beta ./ (param.beta + exp(-2*n*param.alpha)) - 1;
