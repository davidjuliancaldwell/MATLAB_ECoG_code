function d = dx_dy(x,y,settings)

% Copyright 2012 The MathWorks, Inc.

Q = size(x,2);
dq = zeros(settings.yrows,settings.xrows);
for i=1:length(settings.keep_ind)
  dq(settings.keep_ind(i),i) = 1;
end
d = cell(1,Q);
d(:) = {dq};
