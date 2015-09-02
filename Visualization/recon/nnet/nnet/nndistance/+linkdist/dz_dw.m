function dz = dz_dw(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

[R,Q] = size(p);
dz = zeros(R,Q);
