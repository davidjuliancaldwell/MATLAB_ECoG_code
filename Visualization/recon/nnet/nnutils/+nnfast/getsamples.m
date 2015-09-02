function y = getsamples(x,ind)
%GETSAMPLES_FAST (STRICTNNDATA,IND)

% Copyright 2010 The MathWorks, Inc.

y = cell(size(x));
for j = 1:numel(y)
  y{j} = x{j}(:,ind);
end
