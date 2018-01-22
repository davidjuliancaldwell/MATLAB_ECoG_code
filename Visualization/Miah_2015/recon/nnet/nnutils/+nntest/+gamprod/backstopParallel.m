function dw = backstopParallel(dz,w,p,z,param)

% Copyright 2012 The MathWorks, Inc.

% dz = SxQxN
% w = Sx1, only 1st element used
% p = RxQ
% z = SxQ

[S,Q,N] = size(dz);
R = size(p,1);
TruncateS = max(0,min(R-1,S));

dw = zeros(S,1,Q,N); % Sx1xQxN
if (TruncateS == 0) || isempty(dw), return, end

p = reshape(p,R,1,Q); % Rx1xQ
dz = reshape(dz(1:TruncateS,:,:),TruncateS,1,Q,N); % TruncaseSx1xQxN

d = p(1:TruncateS,1,:)-p(2:TruncateS+1,1,:)+1; % TruncateSx1xQxN

dw(1,1,:,:) = sum(bsxfun(@times,dz,d),1); % 1x1xQxN
