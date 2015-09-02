function d = da_dn(n,a,param)

% Copyright 2012 The MathWorks, Inc.

[S,Q] = size(n);
d = cell(1,Q);
for q=1:Q
  nq = n(:,q);
  aq = a(:,q);
  dq = 2*(gmultiply(aq',aq).*nq(:,ones(1,S))' - diag(aq.*nq));
  d{q} = dq;
end
