function dp = backprop(dz,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% dz = SxQxN
% w = Sx1, only 1st element used
% p = RxQ
% z = SxQ

[S,Q,N] = size(dz);
R = size(p,1);
TruncateS = max(0,min(R-1,S));
TruncateR = max(0,min(R,S+1));

if (TruncateS == 0)
  dp = zeros(R,Q,N);
  return;
end

dz = reshape(dz(1:TruncateS,:,:),TruncateS,1,Q,N); % TruncteSx1xQxN

d1 = diag(w(1:TruncateS)); % TruncaseSxTruncateS
zeros1 = zeros(TruncateS,1); % TruncateSx1
d = [d1 zeros1] + [zeros1 -d1]; % TruncateSxTruncateR

dp = zeros(R,Q,N); % RxQxN
dp1 = sum(bsxfun(@times,dz,d),1); % TruncaseSxTruncateR
dp(1:TruncateR,:,:) = reshape(dp1,TruncateR,Q,N); %TruncateRxQxN
