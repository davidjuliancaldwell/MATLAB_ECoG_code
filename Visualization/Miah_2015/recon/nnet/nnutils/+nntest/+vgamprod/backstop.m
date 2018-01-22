function dw = backstop(dz,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% dz = SxQ
% w = Sx1, only 1st element used
% p = RxQ
% z = SxQ

[S,Q] = size(z);
R = size(p,1);
TruncateS = max(0,min(R-1,S));
TruncateR = max(0,min(R,S+1));

d = p(1:TruncateS,:)-p(2:TruncateR,:)+1; % TruncateSxQ

dw = zeros(S,1);
dw(1:TruncateS) = sum(bsxfun(@times,dz(1:TruncateS,:),d),2);
