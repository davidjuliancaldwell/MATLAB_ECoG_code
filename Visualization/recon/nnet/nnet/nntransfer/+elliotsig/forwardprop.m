function da = forwardprop(dn,n,a,param)
%TANSIG.FORWARDPROP

% Copyright 2012 The MathWorks, Inc.

d = 1 ./ ((1+abs( n)).^2);
da = bsxfun(@times,dn,d);

