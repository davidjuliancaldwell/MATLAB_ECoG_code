function dw = backstopParallel(dz,w,p,z,param)
%DOTPROD.BACKSTOP_PARALLEL

% Copyright 2012 The MathWorks, Inc.

[S,Q,N] = size(dz);
R = size(p,1);

p = reshape(p,1,R,Q);
z = reshape(z,S,1,Q);
dz = reshape(dz,S,1,Q,N);

z(z==0) = 1;
d = bsxfun(@rdivide,bsxfun(@minus,w,p),z);
d(isnan(d)) = 0;

dw = bsxfun(@times,d,dz);
