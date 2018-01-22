function dz_dw = forwardstart(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

[S,R] = size(w);
Q = size(p,2);
dz_dw = zeros(S,Q,S,R);

sump = sum(abs(p),1);
dividep = 1 ./ sump;
dividep(sump == 0) = 0;
dividep(~isfinite(dividep)) = 0;
normpt = bsxfun(@times,p,dividep)';
for i=1:S
  dz_dw(i,:,i,:) = normpt;
end
