function dw = backstop(dz,w,p,z,param)
%DOTPROD.BACKSTOP

% Copyright 2012 The MathWorks, Inc.

% dz = SxQ
% w = SxR
% p = RxQ

dw = dz * p'; % SxR
