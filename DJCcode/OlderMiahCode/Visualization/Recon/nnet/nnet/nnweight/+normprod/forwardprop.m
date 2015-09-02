function dz = forwardprop(dp,w,p,z,param)
%DOTPROD.FORWARDPROP

% Copyright 2012 The MathWorks, Inc.

[R,Q,N] = size(dp);
S = size(z,1);

if (R == 1)
  dz = zeros(S,Q,N);
else
  dz = zeros(S,Q,N);
  sump = sum(abs(p),1);
  dividep = 1 ./ sump;
  dividep(sump == 0) = 0;
  dividep(~isfinite(dividep)) = 0;
  signp = sign(p);
  for q=1:Q
    dq = (w - bsxfun(@times,signp(:,q)',z(:,q))) * dividep(q);
    dzq = sum(bsxfun(@times,dq',dp(:,q,:)),1);
    dz(:,q,:) = reshape(dzq,S,1,N);
  end
end
