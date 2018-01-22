function flag = discontinuity(n,param)

% Copyright 2012 The MathWorks, Inc.

flag = sum(bsxfun(@eq,n,max(n,[],1))) > 1;




