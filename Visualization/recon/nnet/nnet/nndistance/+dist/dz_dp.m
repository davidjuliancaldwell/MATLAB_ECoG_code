function d = dz_dp(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

Q = size(p,2);
p = p';
d = cell(1,Q);
z(z==0) = 1;
for q=1:Q
  zq = z(:,q);
  dq = bsxfun(@rdivide,bsxfun(@minus,p(q,:),w),zq);
  dq(isnan(dq)) = 0;
  d{q} = dq;
end
