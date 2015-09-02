function a = apply(n,param)
%HARDLIM.APPLY

% Copyright 2012 The MathWorks, Inc.

a = 2*(n >= 0)-1;
a(isnan(n)) = nan;
