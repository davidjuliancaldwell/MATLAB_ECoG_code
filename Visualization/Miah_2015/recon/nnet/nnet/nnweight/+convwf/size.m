function dim = size(s,r,param)

% Copyright 2012 The MathWorks, Inc.

if (s > r) || (s == 0), error(message('nnet:convwf:Dimensions')); end
dim = [(r-s+1) 1];
