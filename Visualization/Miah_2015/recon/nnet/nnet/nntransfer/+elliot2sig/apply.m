function a = apply(n,param)

% Copyright 2012 The MathWorks, Inc.

n2 = n.*n; 
a = sign(n).*n2 ./ (1 + n2);

