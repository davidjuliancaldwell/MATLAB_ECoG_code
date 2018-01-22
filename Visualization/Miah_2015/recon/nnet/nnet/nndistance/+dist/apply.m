function z = apply(w,p,param)

% Copyright 2012 The MathWorks, Inc.

[S,R] = size(w);
Q = size(p,2);

p = reshape(p,1,R,Q);
z = sqrt(reshape(sum(bsxfun(@minus,w,p).^2,2),S,Q));
