function d = dy_dx_full(processFcn,x,y,settings,Q)

% Copyright 2012 The MathWorks, Inc.

d = processFcn.dy_dx(x,y,settings);

if ~iscell(d)
  d2 = cell(1,Q);
  d2(:) = {d};
  d = d2;
end
