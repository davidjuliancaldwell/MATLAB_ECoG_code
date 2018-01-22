function dz_dw = forwardstart(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% W = SxR
% P = RxQ
% Z = SxQ

[S,R] = size(w);
Q = size(p,2);

p = reshape(p',1,Q,1,R); % 1xQx1xR
w = reshape(w,S,1,1,R); % Sx1x1xR

d = bsxfun(@times,2*sum(bsxfun(@times,w,p),4),p); % SxQx1xR
dz_dw = zeros(S,Q,S,R); % SxQxSxR
for i=1:S
  dz_dw(i,:,i,:) = d(i,:,1,:);
end
