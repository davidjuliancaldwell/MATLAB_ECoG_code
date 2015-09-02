function z = apply(w,p,param)

% Copyright 2012 The MathWorks, Inc.

% w = Sx1, only 1st element used
% p = RxQ

S = size(w,1);
[R,Q] = size(p);

if (S==0)
  z = zeros(0,Q);
  return
end

w = w(1);

TruncateS = max(0,min(R-1,S));
PadS = max(0,S-TruncateS);
z = [w*(p(1:TruncateS,:) - p(2:TruncateS+1,:)+1); zeros(PadS,Q)];

% z = SxQ
