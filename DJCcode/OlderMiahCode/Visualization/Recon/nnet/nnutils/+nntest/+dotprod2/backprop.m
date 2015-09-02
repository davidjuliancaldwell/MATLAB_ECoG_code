function dp = backprop(dz,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

[S,Q,N] = size(dz);
R = size(p,1);

p = reshape(p,1,R,Q);
dz = reshape(dz,S,1,Q,N);

d = bsxfun(@times,2*sum(bsxfun(@times,w,p),2),w);

dp = sum(bsxfun(@times,d,dz),1);
dp = reshape(dp,R,Q,N);
