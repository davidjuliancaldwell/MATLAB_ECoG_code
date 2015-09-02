function dw = backstopParallel(dz,w,p,z,param)
%DOTPROD.BACKSTOP_PARALLEL

% Copyright 2012 The MathWorks, Inc.

% dz = SxQxN
% w = SxR
% p = RxQ
% z = SxQ

[S,Q,N] = size(dz);
R = size(p,1);

dz = reshape(dz,S,1,Q,N); % Sx1xQxN
p = reshape(p,1,R,Q); % 1xRxQ
dw = bsxfun(@times,dz,p); % SxRxQxN
