function a = apply(n,param)
%COMPET.APPLY

% Copyright 2012 The MathWorks, Inc.

if isempty(n)
  a = n;
else
  [S,Q] = size(n);
  nanInd = any(isnan(n),1);
  
  a = zeros(S,Q);
  [~,rows] = max(n,[],1);
  onesInd = rows + S*(0:(Q-1));
  a(onesInd) = 1;
  
  a(:,nanInd) = NaN;
end
