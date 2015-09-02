function d = dz_dp_num(info,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% Returns 1xQ cell of RxS double

if ischar(info)
  info = nnModuleInfo(info);
end

delta = 1e-7;
[S,R] = size(z);
[R,Q] = size(p);
d = cell(1,Q);
for q=1:Q
  pq = p(:,q);
  dq = zeros(S,R);
  for i=1:R
    z1 = info.apply(w,addp(pq,i,+2*delta),param);
    z2 = info.apply(w,addp(pq,i,+delta),param);
    z3 = info.apply(w,addp(pq,i,-delta),param);
    z4 = info.apply(w,addp(pq,i,-2*delta),param);
    dq(:,i) = (-z1 + 8*z2 - 8*z3 + z4) / (12*delta);
  end
  d{q} = dq;
end

function n = addp(n,i,v)
n(i) = n(i) + v;

