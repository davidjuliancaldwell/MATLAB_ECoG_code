function dz = forwardprop(dp,w,p,z,param)
%DOTPROD.FORWARDPROP

% Copyright 2012 The MathWorks, Inc.

[~,Q,N] = size(dp);
S = size(z,1);
dz = zeros(S,Q,N);
