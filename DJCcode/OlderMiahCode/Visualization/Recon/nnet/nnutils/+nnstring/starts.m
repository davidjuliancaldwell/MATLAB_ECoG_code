function flag = nn_str_starts_with(str,startStr)

% Copyright 2010 The MathWorks, Inc.

if length(str) < length(startStr)
  flag = false;
else
  flag = all(str(1:length(startStr)) == startStr);
end
