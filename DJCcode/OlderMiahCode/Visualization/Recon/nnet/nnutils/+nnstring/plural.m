function str = nn_plural(n,s)

% Copyright 2010 The MathWorks, Inc.

if n == 1
  str = s;
else
  if s(end) == 's'
    str = [s 'es'];
  elseif s(end) == 'x'
    str = [s(1:(end-1)) 'ces'];
  else
    str = [s 's'];
  end
end
