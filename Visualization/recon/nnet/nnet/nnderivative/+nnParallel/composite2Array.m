function y = composite2Array(x)

% Copyright 2012 The MathWorks, Inc.

count = numel(x);
y = zeros(1,count);
for i=1:count
  y(i) = x{i};
end
