function y = cell2Composite(x)

% Copyright 2012 The MathWorks, Inc.

y = Composite;
count = numel(y);
for i=1:count
  y{i} = x{i};
end
