function d = dz_dp(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

[S,R] = size(w);
Q = size(p,2);
d = cell(1,Q);
if (R == 1)
  d(:) = {zeros(S,R)};
else
  sump = sum(abs(p),1);
  dividep = 1 ./ sump;
  dividep(sump == 0) = 0;
  dividep(~isfinite(dividep)) = 0;
  signp = sign(p);
  for q=1:Q
    d{q} = (w - bsxfun(@times,signp(:,q)',z(:,q))) * dividep(q);
  end
end
