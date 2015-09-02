function dp = backprop(dz,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

[S,Q,N] = size(dz);
R = size(p,1);

p = reshape(p,1,R,Q); % 1xRxQ

z(z==0)=1;
z = reshape(z,S,1,Q); % Sx1xQ

dz = reshape(dz,S,1,Q,N); % Sx1xQxN

d = bsxfun(@rdivide,bsxfun(@minus,p,w),z); %SxRxQ
d(isnan(d)) = 0;

dp = sum(bsxfun(@times,d,dz),1);
dp = reshape(dp,R,Q,N);
