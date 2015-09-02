function flag = discontinuity(w,p,param)

% Copyright 2012 The MathWorks, Inc.

z = negdist(w,p);
flag = any(z==0,1);
