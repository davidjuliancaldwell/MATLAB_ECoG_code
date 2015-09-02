function d = dz_dp(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% w = SxR
% p = RxQ
% z = SxQ

Q = size(p,2);

d = cell(1,Q);
for q=1:Q
  z1 = bsxfun(@minus,p(:,q)',w);
  d{q} = sign(z1);
end
