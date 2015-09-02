function d = dz_dp(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

z1 = w*p;
[S,R] = size(w);
Q = size(p,2);
d = cell(1,Q);
for q = 1:Q
  dq = zeros(S,R);
  for i=1:S
    dq(i,:) = 2*z1(i,q)*w(i,:);
  end
  d{q} = dq;
end
