function dz = forwardprop(dp,w,p,z,param)
%DOTPROD.FORWARDPROP

% Copyright 2012 The MathWorks, Inc.

[R,Q,N] = size(dp);
S = size(z,1);

p = reshape(p,1,R,Q);
z(z==0) = 1;
z = reshape(z,S,1,Q);
dp = reshape(dp,1,R,Q,N);

d = bsxfun(@rdivide,bsxfun(@minus,p,w),z);
d(isnan(d)) = 0;

dz = sum(bsxfun(@times,d,dp),2);
dz = reshape(dz,S,Q,N);
