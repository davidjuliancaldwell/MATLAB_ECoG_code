function flag = discontinuity(w,p,param)

% Copyright 2012 The MathWorks, Inc.

% w = SxR
% p = RxQ

[S,R] = size(w);
Q = size(p,2);

p = reshape(p,1,R,Q); % 1xRxQ

z = any(any(bsxfun(@minus,w,p)==0,1),2); % 1x1xQ
flag = reshape(z,1,Q); % 1xQ
