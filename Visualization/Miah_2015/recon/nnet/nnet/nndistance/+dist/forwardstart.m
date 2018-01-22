function dw = forwardstart(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% W = SxR
% P = RxQ
% Z = SxQ

[S,R] = size(w);
Q = size(p,2);

p = reshape(p',1,Q,1,R); % 1xQx1xR
w = reshape(w,S,1,1,R); % Sx1x1xR

z(z==0) = 1;
d = bsxfun(@rdivide,bsxfun(@minus,w,p),z); % SxQx1xR
d(isnan(d)) = 0;

dw = zeros(S,Q,S,R); % SxQxSxR
for i=1:S
  dw(i,:,i,:) = d(i,:,1,:);
end
