function da = forwardprop(dn,n,a,param)
%TANSIG.FORWARDPROP

% Copyright 2012 The MathWorks, Inc.

n2 = n .* n;  
d = 2*sign(n).*n ./ ((1+n2).^2);
da = bsxfun(@times,dn,d);

