function flag = discontinuity(w,p,param)

% Copyright 2012 The MathWorks, Inc.

% w = SxR
% p = RxQ

[S,R] = size(w);
Q = size(p,2);

if (R==0)
  flag = false(1,Q);
  return
end

p = reshape(p,1,R,Q); % 1xRxQ

z1 = bsxfun(@minus,p,w); % SxRxQ
z2 = abs(z1); % SxRxQ
z3 = max(abs(z2),[],2); % Sx1xQ

flag1 = sum(bsxfun(@eq,z1,z3),2) > 1; % Sx1xQ
flag2 = all(z1 == 0,2); % Sx1xQ

flag = any(flag1 | flag2,1); % 1x1xQ
flag = reshape(flag,1,Q);


