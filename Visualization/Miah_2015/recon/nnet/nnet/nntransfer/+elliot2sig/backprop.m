function dn = backprop(da,n,a,param)
%TANSIG.BACKPROP

% Copyright 2012 The MathWorks, Inc.

n2 = n .* n;  
d = 2*sign(n).*n ./ ((1+n2).^2);
dn = bsxfun(@times,da,d);


