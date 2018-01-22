function d = dz_dp(w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% w = Sx1, only 1st element used
% p = RxQ
% z = SxQ

S = size(z,1);
R = size(p,1);

if (S==0) || (R<2)
  d = zeros(S,R);
  return
end

TruncateS = max(0,min(R-1,S));
TruncateR = max(0,min(R,S+1));
PadS = max(0,S-TruncateS);
PadR = max(0,R-TruncateS);

d1 = diag(w(1:TruncateS)); % TruncateSxTruncateS
zeros1 = zeros(TruncateS,PadR);
zeros2 = zeros(TruncateS,1);
zeros3 = zeros(TruncateS,PadR-1);
zeros4 = zeros(PadS,R);
d = [[d1 zeros1] + [zeros2 -d1 zeros3]; zeros4];

% d = SxR
