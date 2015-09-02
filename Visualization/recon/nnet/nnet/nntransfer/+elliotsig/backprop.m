function dn = backprop(da,n,a,param)

% Copyright 2012 The MathWorks, Inc.

d = 1 ./ ((1+abs( n)).^2);
dn = bsxfun(@times,da,d);


