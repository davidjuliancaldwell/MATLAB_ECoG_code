function dz = forwardprop(dp,w,p,z,param)
%DOTPROD.FORWARDPROP

% Copyright 2012 The MathWorks, Inc.

[R,Q,N] = size(dp);
S = size(z,1);
M = length(w);
pframe = 0:(M-1);

dz = zeros(S,Q,N);
for i=1:S
  dz(i,:) = dz(i,:) + w' * dp(i+pframe,:);
end
