function dw = forwardstart(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

[S,R] = size(w);
Q = size(p,2);
dw = zeros(S,Q,S,R);
