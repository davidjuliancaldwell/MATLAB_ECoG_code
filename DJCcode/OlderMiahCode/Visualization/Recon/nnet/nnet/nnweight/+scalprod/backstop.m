function dw = backstop(dz,w,p,z,param)
%DOTPROD.BACKSTOP

% Copyright 2012 The MathWorks, Inc.

dw = bsxfun(@times,dz,p);
dw = sum(dw(:));
