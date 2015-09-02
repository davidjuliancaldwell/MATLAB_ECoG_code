function n = numnan(x)
%NUMNAN_FAST Fast no-type checking/formatting version of NUMNAN
%
%  n = nnfast.numnan(x)

% Copyright 2010 The MathWorks, Inc.

n = 0;
for i=1:numel(x)
  n = n + sum(sum(isnan(x{i})));
end

  
