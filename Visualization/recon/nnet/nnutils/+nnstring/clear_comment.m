function x = clear_comment(x)
%NN_CLEAR_COMMENT Replace comments with # in one or more lines of code.

% Copyright 2010-2012 The MathWorks, Inc.

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
  
  % Comment: Block out line as #
  if x(ind) == '%'
    x((ind+1):end) = '#';
    return
  end
  
  % Quote as first char, or following whitespace: Skip string
  if (ind==1) || any(x(ind-1) == [8 32 39 40 44 59 61 91 123])
    j = i+1;
    while (x(inds(j))=='%'), j = j + 1; end
    i = j + 1;
    
  % Quote not after whitespace is transpose, skip quote
  else
    i = i + 1;
  end
end
