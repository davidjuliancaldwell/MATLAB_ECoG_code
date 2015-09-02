function dz = forwardstart(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

[S,Q] = size(z);
R = size(p,1);
M = length(w);
pframe = 0:(M-1);

pt = reshape(p',1,Q,R);
dz = zeros(S,Q,M);
for i=1:S
  dz(i,:,:) = dz(i,:,:) + pt(:,:,i+pframe);
end
