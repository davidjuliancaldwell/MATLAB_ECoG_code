function dw = backstop(dz,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% dz = SxQ
% w = SxR
% p = RxQ
% z = SxQ

[S,Q] = size(dz);
R = size(p,1);

p = reshape(p,1,R,Q); % 1xRxQ
z = reshape(z,S,1,Q); % Sx1xQ
dz = reshape(dz,S,1,Q); % Sx1xQ

d = bsxfun(@rdivide,bsxfun(@minus,w,p),z); % SxRxQ
d(isnan(d)) = 0;

dw = sum(bsxfun(@times,d,dz),3); % SxR
