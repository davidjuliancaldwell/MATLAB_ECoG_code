function dp = backprop(dz,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

[S,Q,N] = size(dz);
R = size(p,1);

if (R == 1)
  dp = zeros(R,Q,N);
else
  dp = zeros(R,Q,N);
  sump = sum(abs(p),1);
  dividep = 1 ./ sump;
  dividep(sump == 0) = 0;
  dividep(~isfinite(dividep)) = 0;
  signp = sign(p);
  for q=1:Q
    dq = (w - bsxfun(@times,signp(:,q)',z(:,q))) * dividep(q);
    dpq = sum(bsxfun(@times,dq,dz(:,q,:)),1);
    dp(:,q,:) = reshape(dpq,R,1,N);
  end
end
