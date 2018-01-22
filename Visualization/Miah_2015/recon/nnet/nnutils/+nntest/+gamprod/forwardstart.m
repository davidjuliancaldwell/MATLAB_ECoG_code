function dz_dw = forwardstart(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% W = SxR
% P = RxQ
% Z = SxQ

[S,Q] = size(z);
R = size(p,1);
TruncateS = max(0,min(R-1,S));

dz_dw = zeros(S,Q,S,1); % SxQxSx1
if (TruncateS < 1), return; end

dz_dw(1:TruncateS,:,1,1) = p(1:TruncateS,:) - p(2:TruncateS+1,:) + 1; % truncateSxQx1x1
