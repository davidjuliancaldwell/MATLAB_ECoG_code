function z = apply(w,p,param)
%NORMPROD.APPLY

% Copyright 2012 The MathWorks, Inc.

p = p + 1e-20*sign(p);
sump = sum(abs(p),1);
dividep = 1 ./ sump;
dividep(sump == 0) = 0;
dividep(~isfinite(dividep)) = 0;
normp = bsxfun(@times,p,dividep);
z = w * normp;

% Multiplying by the reciprocal of sump instead of
% dividing by sump produces more accurate results and
% a better match with numerical derivatives.
