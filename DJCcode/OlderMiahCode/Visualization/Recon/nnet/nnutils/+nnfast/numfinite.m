function n = numfinite(x)
%NUMFINITE_FAST Fast no-type checking/formatting version of NUMFINITE
%
%  n = nnfast.numfinite(x)

% Copyright 2010 The MathWorks, Inc.

n = 0;
for i=1:numel(x)
  n = n + sum(sum(isfinite(x{i})));
end

  
