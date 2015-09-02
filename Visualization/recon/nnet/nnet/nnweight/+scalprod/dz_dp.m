function d = dz_dp(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

R = size(p,1);
d = w*eye(R);
