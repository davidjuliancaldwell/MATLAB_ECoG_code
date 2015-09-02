function dz_dw = forwardstart(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% W = SxR
% P = RxQ
% Z = SxQ

[S,Q] = size(z);
R = size(p,1);
TruncateS = min(R-1,S);

dz_dw = zeros(S,Q,S,1); % SxQxSx1
for i=1:TruncateS
  dz_dw(i,:,i,1) = p(i,:) - p(i+1,:) + 1; % truncateSxQx1x1
end

