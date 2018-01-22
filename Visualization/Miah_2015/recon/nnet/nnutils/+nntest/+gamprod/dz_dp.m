function d = dz_dp(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% w = Sx1, only 1st element used
% p = RxQ
% z = SxQ

S = size(z,1);
R = size(p,1);
TruncateS = max(0,min(R-1,S));
PadS = max(0,S-TruncateS);

if (R==0) || (S==0)
  d = zeros(S,R);
  return
end

w = w(1);

d1 = diag(w*ones(1,TruncateS)); % TruncateSxTruncateS
zeros1 = zeros(TruncateS,R-TruncateS);
zeros2 = zeros(TruncateS,1);
zeros3 = zeros(TruncateS,R-TruncateS-1);
zeros4 = zeros(PadS,R);
d = [[d1 zeros1] + [zeros2 -d1 zeros3]; zeros4];

% d = SxR
