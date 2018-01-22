function dp = backprop(dz,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

[~,Q,N] = size(dz);
R = size(p,1);
dp = zeros(R,Q,N);
