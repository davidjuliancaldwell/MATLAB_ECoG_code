function dw = backstop(dz,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% dz = SxQ
% w = Sx1, only 1st element used
% p = RxQ
% z = SxQ

S = size(z,1);
R = size(p,1);
TruncateS = max(0,min(R-1,S));

d = p(1:TruncateS,:)-p(2:TruncateS+1,:)+1; % TruncateSxQ

dw = zeros(S,1);
dw(1) = sum(sum(bsxfun(@times,dz(1:TruncateS,:),d),1),2);
