function d = dz_dp(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

[R,Q] = size(p);
N = length(w);
S = R-N+1;
ww = w(:,ones(1,R))';
if numel(ww) == 1
  % Avoids SPDIAGS(X,0,0) bug
  d = ww;
else
  d = full(spdiags(ww,[0:-1:-(N-1)],zeros(R,S)))';
end
