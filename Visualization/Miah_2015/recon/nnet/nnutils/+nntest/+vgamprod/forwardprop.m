function dz = forwardprop(dp,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% dp = RxQxN
% w = SxR
% p = RxQ
% z = SxQ

[R,Q,N] = size(dp);
S = size(z,1);
TruncateS = max(0,min(R-1,S));
TruncateR = max(0,min(R,S+1));

dp = reshape(dp(1:TruncateR,:,:),1,TruncateR,Q,N); % 1xTruncateRxQxN

d1 = diag(w(1:TruncateS)); % TruncaseSxTruncateS
zeros1 = zeros(TruncateS,1); % TruncateSx1
d = [d1 zeros1] + [zeros1 -d1]; % TruncateSxTruncateR

dz = zeros(S,Q,N); % SxQxN
dz1 = sum(bsxfun(@times,dp,d),2); % TruncaseSx1xQxN
dz(1:TruncateS,:,:) = reshape(dz1,TruncateS,Q,N); % TruncateSxQxN
