function d = dy_dx_num(info,x,y,settings)

% Copyright 2012 The MathWorks, Inc.

if ischar(info)
  info = feval(fcn);
end

delta = 1e-7;
[N,Q] = size(x);
M = size(y,1);
d = cell(1,Q);
for q=1:Q
  dq = zeros(M,N);
  xq = x(:,q);
  for i=1:N
    y1 = info.apply(addx(xq,i,-2*delta),settings);
    y2 = info.apply(addx(xq,i,-delta),settings);
    y3 = info.apply(addx(xq,i,+delta),settings);
    y4 = info.apply(addx(xq,i,+2*delta),settings);
    dq(:,i) = (y1 - 8*y2 + 8*y3 - y4) / (12*delta);
  end
  d{q} = dq;
end

function x = addx(x,i,v)
x(i) = x(i) + v;
