function dw = backstopParallel(dz,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% dz = SxQxN
% w = SxR
% p = RxQ
% z = SxQ

[S,Q,N] = size(dz);
R = size(p,1);

p = reshape(p,1,R,Q); % 1xRxQ
dz = reshape(dz,S,1,Q,N); % Sx1xQxN

z1 = bsxfun(@minus,w,p); % SxRxQ

d = sign(z1); % SxRxQ

dw = bsxfun(@times,d,dz); % SxRxQxN
