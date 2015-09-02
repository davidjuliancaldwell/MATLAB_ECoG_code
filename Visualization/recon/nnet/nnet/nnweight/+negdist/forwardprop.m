function dz = forwardprop(dp,w,p,z,param)
%DOTPROD.FORWARDPROP

% Copyright 2012 The MathWorks, Inc.

% dp = RxQxN
% w = SxR
% p = RxQ
% z = SxQ

[R,Q,N] = size(dp);
S = size(z,1);

p = reshape(p,1,R,Q); % 1xRxQ
z = reshape(z,S,1,Q); % Sx1xQ
dp = reshape(dp,1,R,Q,N); % 1xRxQxN

d = bsxfun(@rdivide,bsxfun(@minus,p,w),z); % SxRxQ
d(isnan(d)) = 0;

dz = sum(bsxfun(@times,d,dp),2); % Sx1xQxN
dz = reshape(dz,S,Q,N); % SxQxN
