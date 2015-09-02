function dw = backstop(dz,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% dz = SxQ
% w = SxR
% p = RxQ
% z = SxQ

sump = sum(abs(p),1); % 1xQ
dividep = 1 ./ sump; % 1xQ
dividep(sump == 0) = 0; % 1xQ
dividep(~isfinite(dividep)) = 0;
normp = bsxfun(@times,p,dividep); % RxQ
dw = dz * normp'; % SxR
