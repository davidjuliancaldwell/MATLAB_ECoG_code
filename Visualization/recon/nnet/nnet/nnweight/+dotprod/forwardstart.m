function dz_dw = forwardstart(w,p,z,param)
%DOTPROD.FORWARDSTART

% Copyright 2012 The MathWorks, Inc.

% W = SxR
% P = RxQ
% Z = SxQ

[S,R] = size(w);
Q = size(p,2);

pt = reshape(p',1,Q,1,R); % 1xQx1xR

dz_dw = zeros(S,Q,S,R); % SxQxSxR
for i=1:S
  dz_dw(i,:,i,:) = pt;
end
