function d = dx_dy(x,y,settings)

% Copyright 2012 The MathWorks, Inc.

Q = size(x,2);
d = cell(1,Q);
finiteX = ~isnan(x);
for q=1:Q
  dq = zeros(settings.xrows,settings.yrows);
  dq(:,(1:settings.xrows)+settings.shift) = diag(finiteX(:,q));
  d{q} = dq;
end
