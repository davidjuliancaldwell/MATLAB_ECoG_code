function dp = backprop(dz,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

[S,Q,N] = size(dz);
R = size(p,1);
M = length(w);
pframe = 0:(M-1);

dp = zeros(R,Q,N);
for i=1:S
  dp(i+pframe,:) = dp(i+pframe,:) + bsxfun(@times,w,dz(i,:));
end
