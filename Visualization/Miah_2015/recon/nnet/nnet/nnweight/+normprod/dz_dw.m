function d = dz_dw(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

[R,Q] = size(p);
if (R == 1)
  d = sign(p);
else
  sump = sum(abs(p),1);
  dividep = 1 ./ sump;
  dividep(sump == 0) = 0;
  dividep(~isfinite(dividep)) = 0;
  d = bsxfun(@times,p,dividep);
end
