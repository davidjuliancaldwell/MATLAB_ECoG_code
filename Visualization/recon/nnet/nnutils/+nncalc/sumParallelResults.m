function c = sumParallelResults(a,b)

% Copyright 2012 The MathWorks, Inc.

c = cell(size(a));
for i=1:numel(a)
  c{i} = a{i}+b{i};
end
