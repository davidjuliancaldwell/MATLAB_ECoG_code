function d = dz_dw(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% w = Sx1, only 1st element used
% p = RxQ
% z = SxQ

[S,Q] = size(z);
R = size(p,1);
TruncateS = max(0,min(R-1,S));

d1 = p(1:TruncateS,:)-p(2:TruncateS+1,:) + 1;
d1 = reshape(d1,1,TruncateS,Q);

d = zeros(S,S,Q);
for i=1:TruncateS
  d(i,i,:) = d1(1,i,:);
end
