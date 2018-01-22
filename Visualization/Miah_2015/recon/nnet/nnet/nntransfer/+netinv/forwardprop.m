function da = forwardprop(dn,n,a,param)
%TANSIG.FORWARDPROP

% Copyright 2012 The MathWorks, Inc.

d = -1./(n.^2);
d = max(d,-1e60);
da = bsxfun(@times,dn,d);
