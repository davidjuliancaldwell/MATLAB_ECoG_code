function d = da_dn(n,a,param)

% Copyright 2012 The MathWorks, Inc.

[S,Q] = size(a);
d = cell(1,Q);
d(:) = {zeros(S,S)};
