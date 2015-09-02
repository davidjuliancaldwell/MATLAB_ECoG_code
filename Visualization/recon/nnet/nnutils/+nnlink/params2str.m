function s = params2str(p)

% Copyright 2010 The MathWorks, Inc.

n = length(p);
if n == 0
  s = '(none)';
else
  s = ['[1x' num2str(n) ' nnetParamInfo array]'];
end
