function y = composite2Cell(x)

% Copyright 2012 The MathWorks, Inc.

count = numel(x);
y = cell(1,count);
for i=1:count
  y{i} = x{i};
end
