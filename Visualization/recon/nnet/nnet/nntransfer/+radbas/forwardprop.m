function da = forwardprop(dn,n,a,param)
%TANSIG.FORWARDPROP

% Copyright 2012 The MathWorks, Inc.

da = bsxfun(@times,dn,-2*n.*a);
