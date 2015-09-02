function d = dz_dw(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% w = Sx1, only 1st element used
% p = RxQ
% z = SxQ

[S,Q] = size(z);

d = zeros(S,S,Q);
if isempty(d), return; end

R = size(p,1);
TruncateS = max(0,min(R-1,S));

d1 = p(1:TruncateS,:)-p(2:TruncateS+1,:) + 1;
d1 = reshape(d1,TruncateS,1,Q);

d(1:TruncateS,1,:) = d1;

% d = SxSxQ, all zeros except for 2nd index == 1, for only non-zero weight
