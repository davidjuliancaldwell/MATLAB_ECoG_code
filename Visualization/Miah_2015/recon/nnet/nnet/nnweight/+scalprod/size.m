function dim = weightSize(s,r,param)

% Copyright 2012 The MathWorks, Inc.

if (s ~= r),  error(message('nnet:scalprod:Dimensions')); end
dim = [1 1];
