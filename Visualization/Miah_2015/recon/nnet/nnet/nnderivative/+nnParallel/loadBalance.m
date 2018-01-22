function q = loadBalance(Q,N)

% Copyright 2012 The MathWorks, Inc.

z = [0 ceil((1:(N-1))*(Q/N)) Q];
q = diff(z);
