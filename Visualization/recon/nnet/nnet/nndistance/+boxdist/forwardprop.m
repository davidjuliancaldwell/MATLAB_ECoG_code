function dz = forwardprop(dp,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% dz = SxQxN
% w = SxR
% p = RxQ
% z = SxQ

[R,Q,N] = size(dp);
S = size(z,1);

p = reshape(p,1,R,Q); % 1xRxQ
dp = reshape(dp,1,R,Q,N); % 1xRxQxN

z1 = bsxfun(@minus,p,w); % SxRxQ
z2 = abs(z1); % SxRxQ
z3 = max(abs(z2),[],2); % Sx1xQ

d = bsxfun(@eq,z2,z3) .* sign(z1); % SxRxQ

dz = sum(bsxfun(@times,d,dp),2); % Sx1xQxN
dz = reshape(dz,S,Q,N); % SxQxN
