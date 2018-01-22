function dn = backprop(da,n,a,param)
%TANSIG.BACKPROP

% Copyright 2012 The MathWorks, Inc.

d = -1./(n.^2);
d = max(d,-1e60);
dn = bsxfun(@times,da,d);
