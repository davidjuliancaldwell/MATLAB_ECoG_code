function d = da_dn(n,a,param)

% Copyright 2012 The MathWorks, Inc.

n2 = n .* n;  
d = 2*sign(n).*n ./ ((1+n2).^2);
