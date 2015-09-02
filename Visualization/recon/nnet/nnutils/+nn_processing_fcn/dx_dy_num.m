function d = dx_dy_num(info,x,y,settings)

% Copyright 2012 The MathWorks, Inc.

if ischar(info)
  info = feval(fcn);
end

delta = 1e-7;
[N,Q] = size(x);
M = size(y,1);
d = cell(1,Q);
M = size(y,1);
for q=1:Q
  dq = zeros(N,M);
  yq = y(:,q);
  for i=1:M
    x1 = info.reverse(addx(yq,i,-2*delta),settings);
    x2 = info.reverse(addx(yq,i,-delta),settings);
    x3 = info.reverse(addx(yq,i,+delta),settings);
    x4 = info.reverse(addx(yq,i,+2*delta),settings);
    dq(:,i) = (x1 - 8*x2 + 8*x3 - x4) / (12*delta);
  end
  dq(~isfinite(dq)) = 0;
  d{q} = dq;
end

function x = addx(x,i,v)
x(i) = x(i) + v;
