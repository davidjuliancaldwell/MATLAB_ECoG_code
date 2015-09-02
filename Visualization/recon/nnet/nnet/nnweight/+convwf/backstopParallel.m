function dw = backstopParallel(dz,w,p,z,param)
%DOTPROD.BACKSTOP_PARALLEL

% Copyright 2012 The MathWorks, Inc.

[S,Q,N] = size(dz);
R = size(p,1);
M = length(w);
pframe = 0:(M-1);

dw = zeros(M,Q,N);
for i=1:S
  dw = dw + bsxfun(@times,dz(i,:,:),p(i+pframe,:));
end
dw = reshape(dw,M,1,Q,N);
