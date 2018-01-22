function z = apply(w,p,param)

% Copyright 2012 The MathWorks, Inc.

% w = SxR
% p = RxQ

[S,R] = size(w);
Q = size(p,2);

if (R==0)
  z = zeros(S,Q);
else
  isNaN = any(isnan(p),1);
  p(:,isNaN) = NaN;
  p = reshape(p,1,R,Q); % 1xRxQ
  z = max(abs(bsxfun(@minus,w,p)),[],2); % SxRxQ
  z = reshape(z,S,Q); % SxQ
end
