function d = da_dn(n,a,param)

% Copyright 2012 The MathWorks, Inc.

[S,Q] = size(n);
d = cell(1,Q);
for q=1:Q
  dq = zeros(S,S);
  for i=1:S
    for j=1:S
      if (j==i)
        dq(i,i) = dq(i,j) + a(i,q) .* (1-a(i,q));
      else
        dq(i,j) = dq(i,j) - a(i,q) .* a(j,q);
      end
    end
  end
  d{q} = dq;
end
