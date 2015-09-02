function dz = forwardprop(dp,w,p,z,param)
%DOTPROD.FORWARDPROP

% Copyright 2012 The MathWorks, Inc.

[R,Q,N] = size(dp);
S = size(z,1);
dp = reshape(dp,R,Q*N);
dz = w*dp;
dz = reshape(dz,S,Q,N);
