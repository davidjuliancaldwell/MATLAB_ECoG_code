function d = da_dn(n,a,param)

% Copyright 2012 The MathWorks, Inc.

d = -1./(n.^2);
d(abs(n) <= 1e-30) = -1e60;
