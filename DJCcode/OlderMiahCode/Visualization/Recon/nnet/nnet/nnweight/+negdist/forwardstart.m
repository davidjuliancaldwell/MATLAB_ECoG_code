function dw = forwardstart(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% W = SxR
% P = RxQ
% Z = SxQ

[S,R] = size(w);
Q = size(p,2);

p = reshape(p',1,Q,1,R);
w = reshape(w,S,1,1,R);

d = bsxfun(@rdivide,bsxfun(@minus,w,p),z);
d(isnan(d)) = 0;

dw = zeros(S,Q,S,R);
for i=1:S
  dw(i,:,i,:) = d(i,:,1,:);
end

% dw = SxQxSxR
