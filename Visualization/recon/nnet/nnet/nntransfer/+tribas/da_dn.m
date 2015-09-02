function d = da_dn(n,a,param)

% Copyright 2012 The MathWorks, Inc.

d = ((n >= -1) & (n <= 1)) .* sign(-n);
