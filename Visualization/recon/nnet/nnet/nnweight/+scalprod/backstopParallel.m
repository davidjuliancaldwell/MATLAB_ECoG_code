function dw = backstopParallel(dz,w,p,z,param)
%DOTPROD.BACKSTOP_PARALLEL

% Copyright 2012 The MathWorks, Inc.

[~,Q,N] = size(dz);
dw = bsxfun(@times,dz,p);
dw = reshape(sum(dw,1),1,1,Q,N);
