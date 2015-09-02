function dw = backstopParallel(dz,w,p,z,param)
%DOTPROD.BACKSTOP_PARALLEL

% Copyright 2012 The MathWorks, Inc.

[S,Q,N] = size(dz);
R = size(p,1);
sump = sum(abs(p),1);
dividep = 1 ./ sump;
dividep(sump == 0) = 0;
dividep(~isfinite(dividep)) = 0;
normp = bsxfun(@times,p,dividep);
dw = bsxfun(@times,reshape(dz,S,1,Q,N),reshape(normp,1,R,Q));
