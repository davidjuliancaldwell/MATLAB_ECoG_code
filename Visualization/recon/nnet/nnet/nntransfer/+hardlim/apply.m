function a = apply(n,param)
%HARDLIM.APPLY

% Copyright 2012 The MathWorks, Inc.

a = double(n >= 0);
a(isnan(n)) = nan;
