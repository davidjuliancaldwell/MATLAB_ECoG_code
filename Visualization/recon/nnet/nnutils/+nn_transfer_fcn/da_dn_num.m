function d = da_dn_num(info,n,a,param)

% Copyright 2012 The MathWorks, Inc.

if ischar(info)
  info = nnModuleInfo(info);
end

delta = 1e-6;
[S,Q] = size(n);
d = cell(1,Q);
for q=1:Q
  nq = n(:,q);
  dq = zeros(S,S);
  for i=1:S
    a1 = info.apply(addn(nq,i,+2*delta),param);
    a2 = info.apply(addn(nq,i,+delta),param);
    a3 = info.apply(addn(nq,i,-delta),param);
    a4 = info.apply(addn(nq,i,-2*delta),param);
    dq(:,i) = (-a1 + 8*a2 - 8*a3 + a4) / (12*delta);
  end
  d{q} = dq;
end

function n = addn(n,i,v)
n(i) = n(i) + v;
