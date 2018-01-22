function dw = backstop(dz,w,p,z,param)
%DOTPROD.BACKSTOP

% Copyright 2012 The MathWorks, Inc.

[S,Q] = size(dz);
R = size(p,1);
M = length(w);
pframe = 0:(M-1);

dw = zeros(M,1);
for i=1:S
  dw = dw + p(i+pframe,:)*dz(i,:)';
end
