function x = nn_clear_string(x)
%NN_CLEAR_STRING Replace strings with # in one or more lines of code.

% Copyright 2010 The MathWorks, Inc.

% Cell
if iscell(x)
  for i=1:length(x)
    x{i} = nn_clear_string(x{i});
  end
  return
end

% String
inds = find((x == '''') | (x == '%'));
i = 1;
while (i<=length(inds))
  ind = inds(i);
  if x(ind) == '%', return; end
  if (ind==1) || any(x(ind-1) == [8 32 39 40 44 59 61 91 123])
    j = i+1;
    while(x(inds(j))=='%'), j = j + 1; end
    x((ind+1):(inds(j)-1)) = '#';
    i = j + 1;
  else
    i = i + 1;
  end
end
